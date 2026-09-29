import 'dart:io';
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
import 'package:better_me/features/training/data/exercise_sync_service.dart';

/// The root navigation screen containing the BottomNavigationBar and PageView.
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
  /// Prevents immediate rendering of tabs for smoother splash screen transitions.
  bool _canRenderTabs = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    _runSilentSync();

    // Delays UI rendering and data loading to ensure smooth entry animations.
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

  /// Triggers a background sync for the exercise database based on device language.
  void _runSilentSync() {
    final String deviceLanguage = Platform.localeName.split('_')[0];
    ExerciseSyncService().syncIfNeeded(deviceLanguage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Concurrently fetches diets, trainings, and exercises to populate the Today screen.
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

  /// Handles BottomNavigationBar taps and animates to the selected page.
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Updates state when the PageView is swiped and reloads data if returning to 'Today'.
  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadAllApplicationData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Show empty scaffold during transition delay.
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