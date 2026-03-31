import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';

// Import all your tab screens
import 'package:better_me/features/home/presentation/screens/today_screen.dart';
import 'package:better_me/features/diets/presentation/screens/diets_screen.dart';
import 'package:better_me/features/training/presentation/screens/trainings_screen.dart';
import 'package:better_me/features/profile/presentation/screens/profile_screen.dart';

/// The root navigation handler for the application.
/// Refactored to support dynamic theming and seamless transitions between light/dark modes.
class MainScreen extends StatefulWidget {
  final Profile profile;

  const MainScreen({super.key, required this.profile});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Index tracking the currently selected tab.
  int _selectedIndex = 0;

  // Repositories and Data
  final DietRepository _dietRepo = DietRepository();
  final TrainingRepository _trainingRepo = TrainingRepository();

  List<Diet> _availableDiets = [];
  List<Training> _availableTrainings = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAvailablePlans();
  }

  /// Fetches diets and trainings from the SQLite database.
  Future<void> _loadAvailablePlans() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);

    try {
      if (widget.profile.idProfile != null) {
        _availableDiets = await _dietRepo.getDietsByProfile(widget.profile.idProfile!);
        _availableTrainings = await _trainingRepo.getTrainingsByProfile(widget.profile.idProfile!);
      }
    } catch (e) {
      debugPrint('Error loading plans for MainScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  /// Handles tap events and refreshes data when returning to the Today tab.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _loadAvailablePlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Show a themed loading state
    if (_isLoadingData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // Define the 4 main screens
    final List<Widget> screens = [
      TodayScreen(
        profile: widget.profile,
        availableDiets: _availableDiets,
        availableTrainings: _availableTrainings,
      ),
      DietsScreen(profile: widget.profile),
      TrainingsScreen(profile: widget.profile),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      // IndexedStack preserves the state of each tab (scroll position, etc.)
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Border-based separation for a cleaner look in Dark Mode
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.cardColor, // Adapts to theme (White or Deep Grey)
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary, // Using the theme's green
          unselectedItemColor: theme.hintColor.withValues(alpha: 0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.today_outlined),
              activeIcon: const Icon(Icons.today),
              label: l10n.todayTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_menu_outlined),
              activeIcon: const Icon(Icons.restaurant_menu),
              label: l10n.myDiets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center_outlined),
              activeIcon: const Icon(Icons.fitness_center),
              label: l10n.myWorkouts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}