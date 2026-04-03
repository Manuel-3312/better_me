import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';

import 'package:better_me/features/home/presentation/screens/today_screen.dart';
import 'package:better_me/features/diets/presentation/screens/diets_screen.dart';
import 'package:better_me/features/training/presentation/screens/trainings_screen.dart';
import 'package:better_me/features/profile/presentation/screens/profile_screen.dart';

/// Primary navigation hub for the application.
///
/// Orchestrates bottom navigation and handles the concurrent pre-fetching
/// of application data to ensure a seamless experience. This screen implements
/// a total deferred loading strategy and utilizes a PageView for fluid,
/// swipeable lateral transitions between tabs.
class MainScreen extends StatefulWidget {
  final Profile profile;

  const MainScreen({super.key, required this.profile});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final DietRepository _dietRepo = DietRepository();
  final TrainingRepository _trainingRepo = TrainingRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();

  List<Diet> _availableDiets = [];
  List<Training> _availableTrainings = [];
  Map<int, WgerExercise> _exerciseLookup = {};

  bool _isLoadingData = true;
  bool _canRenderTabs = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 850), () {
        if (mounted) {
          setState(() {
            _canRenderTabs = true;
          });
          _loadAllApplicationData();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Concurrently retrieves necessary local database records.
  ///
  /// Fetches diet plans, training plans, and the comprehensive exercise
  /// lookup dictionary to provide immediate data availability for child screens.
  Future<void> _loadAllApplicationData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);

    try {
      if (widget.profile.idProfile != null) {
        final results = await Future.wait([
          _dietRepo.getDietsByProfile(widget.profile.idProfile!),
          _trainingRepo.getTrainingsByProfile(widget.profile.idProfile!),
          _localDb.getAllExercises(),
        ]);

        if (mounted) {
          setState(() {
            _availableDiets = results[0] as List<Diet>;
            _availableTrainings = results[1] as List<Training>;
            final exercises = results[2] as List<WgerExercise>;
            _exerciseLookup = {for (var e in exercises) e.id: e};
          });
        }
      }
    } catch (e) {
      debugPrint('Data synchronization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  /// Handles navigation when a bottom navigation bar item is tapped.
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Handles state updates when the page is changed via swipe gestures.
  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadAllApplicationData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!_canRenderTabs) {
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor);
    }

    final List<Widget> screens = [
      TodayScreen(
        profile: widget.profile,
        availableDiets: _availableDiets,
        availableTrainings: _availableTrainings,
        exerciseLookup: _exerciseLookup,
        isLoading: _isLoadingData,
      ),
      DietsScreen(profile: widget.profile),
      TrainingsScreen(profile: widget.profile),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.today),
            label: l10n.todayTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: l10n.myDiets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: l10n.myWorkouts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profileTitle,
          ),
        ],
      ),
    );
  }
}
