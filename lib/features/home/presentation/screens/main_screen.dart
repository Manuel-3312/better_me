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

class MainScreen extends StatefulWidget {
  final Profile profile;
  const MainScreen({super.key, required this.profile});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final DietRepository _dietRepo = DietRepository();
  final TrainingRepository _trainingRepo = TrainingRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();

  List<Diet> _availableDiets = [];
  List<Training> _availableTrainings = [];
  Map<int, WgerExercise> _exerciseLookup = {};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAllApplicationData();
  }

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

        _availableDiets = results[0] as List<Diet>;
        _availableTrainings = results[1] as List<Training>;
        final exercises = results[2] as List<WgerExercise>;
        _exerciseLookup = {for (var e in exercises) e.id: e};
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) _loadAllApplicationData();
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.today), label: l10n.todayTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.restaurant_menu), label: l10n.myDiets),
          BottomNavigationBarItem(icon: const Icon(Icons.fitness_center), label: l10n.myWorkouts),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}