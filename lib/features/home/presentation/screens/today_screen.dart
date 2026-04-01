import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/diet_plan.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';

/// Screen responsible for displaying the user's active fitness and nutrition plans for the current day.
///
/// It integrates AI-generated routines with a local exercise database (RAG) to provide
/// rich visual feedback, including execution images and anatomical highlights.
class TodayScreen extends StatefulWidget {
  /// The current user profile containing active plan IDs.
  final Profile profile;

  /// List of all diet plans available to the user.
  final List<Diet> availableDiets;

  /// List of all training plans available to the user.
  final List<Training> availableTrainings;

  /// A pre-loaded map used to fetch detailed exercise data (names, images) by their ID.
  final Map<int, WgerExercise> exerciseLookup;

  /// Flag indicating if data is still being fetched from the database by the parent.
  final bool isLoading;

  const TodayScreen({
    super.key,
    required this.profile,
    required this.availableDiets,
    required this.availableTrainings,
    required this.exerciseLookup,
    required this.isLoading,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();

  Diet? _activeDiet;
  Training? _activeTraining;
  bool _isConfiguring = false;

  @override
  void initState() {
    super.initState();
    _loadInitialConfiguration();
  }

  /// Detects data updates from the parent and refreshes the local active plan state.
  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.availableTrainings != widget.availableTrainings) {
      _loadInitialConfiguration();
    }
  }

  /// Identifies the specific Diet and Training models selected as "active" in the profile.
  void _loadInitialConfiguration() {
    try {
      _activeDiet = widget.availableDiets.firstWhere(
            (d) => d.idDiet == widget.profile.activeDietId,
      );
    } catch (_) {
      _activeDiet = null;
    }

    try {
      _activeTraining = widget.availableTrainings.firstWhere(
            (t) => t.idTraining == widget.profile.activeTrainingId,
      );
    } catch (_) {
      _activeTraining = null;
    }

    setState(() {
      _isConfiguring = (_activeDiet == null || _activeTraining == null);
    });
  }

  /// Determines the zero-based index of the current day within a plan's cycle.
  int _getCurrentDayIndex(int planLength) {
    if (planLength == 0) return 0;
    return (DateTime.now().weekday - 1) % planLength;
  }

  /// Returns the localized string for a specific day of the week.
  String _getWeekdayName(int dayNumber, AppLocalizations l10n) {
    final int normalizedDay = ((dayNumber - 1) % 7) + 1;
    switch (normalizedDay) {
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      case 7: return l10n.sunday;
      default: return '';
    }
  }

  /// Updates the user's active plan selection in the persistent local database.
  Future<void> _saveConfiguration() async {
    if (_activeDiet == null ||
        _activeTraining == null ||
        widget.profile.idProfile == null) {
      return;
    }
    try {
      await _profileRepository.updateActivePlans(
        widget.profile.idProfile!,
        _activeDiet!.idDiet,
        _activeTraining!.idTraining,
      );
      if (mounted) setState(() => _isConfiguring = false);
    } catch (e) {
      debugPrint('Error saving configuration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isConfiguring ? l10n.setupPlanTitle : l10n.todayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!_isConfiguring)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => setState(() => _isConfiguring = true),
            ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isConfiguring
          ? _buildConfigurationView(l10n, theme)
          : _buildDashboardView(l10n, theme),
    );
  }

  /// Renders the setup view when no active plans are configured.
  Widget _buildConfigurationView(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.chooseCurrentFocus,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<Diet>(
            initialValue: _activeDiet,
            decoration: InputDecoration(
              labelText: l10n.activeDiet,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: widget.availableDiets
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() => _activeDiet = v),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<Training>(
            initialValue: _activeTraining,
            decoration: InputDecoration(
              labelText: l10n.activeTraining,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: widget.availableTrainings
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => setState(() => _activeTraining = v),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: (_activeDiet != null && _activeTraining != null)
                ? _saveConfiguration
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              l10n.saveAndStart,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main dashboard containing today's nutrition and workout data.
  Widget _buildDashboardView(AppLocalizations l10n, ThemeData theme) {
    DietPlan? dietPlan;
    if (_activeDiet?.generatedContent != null) {
      dietPlan = DietPlan.fromJson(jsonDecode(_activeDiet!.generatedContent!));
    }

    AiTrainingPlan? trainingPlan;
    if (_activeTraining?.generatedContent != null) {
      trainingPlan = AiTrainingPlan.fromJson(jsonDecode(_activeTraining!.generatedContent!));
    }

    final dDay = dietPlan?.days.isNotEmpty == true
        ? dietPlan!.days[_getCurrentDayIndex(dietPlan.days.length)]
        : null;
    final tDay = trainingPlan?.days.isNotEmpty == true
        ? trainingPlan!.days[_getCurrentDayIndex(trainingPlan.days.length)]
        : null;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(l10n.yourMeals, Icons.restaurant_menu, Colors.orangeAccent),
        if (dDay != null) _buildTodayDietCard(dDay, l10n, theme) else Text(l10n.noDietDataForToday),
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.yourTraining, Icons.fitness_center, Colors.blueAccent),
        if (tDay != null) _buildTodayTrainingCard(tDay, l10n, theme) else Text(l10n.restDayOrNoData),
      ],
    );
  }

  /// Renders a section header with a leading icon.
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Builds a summary card for the current day's diet plan.
  Widget _buildTodayDietCard(DietDay day, AppLocalizations l10n, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.orangeAccent.withValues(alpha: isDarkMode ? 0.4 : 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              _getWeekdayName(day.dayNumber, l10n),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
                fontSize: 18,
              ),
            ),
            trailing: Text(
              '${day.totalCalories} ${l10n.kcal}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          ...day.meals.map((meal) => ExpansionTile(
            shape: const Border(),
            iconColor: Colors.orangeAccent,
            leading: const Icon(Icons.lunch_dining_outlined, size: 20, color: Colors.orangeAccent),
            title: Text(meal.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(meal.type, style: TextStyle(fontSize: 12, color: theme.hintColor)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(52, 0, 16, 20),
                child: Text(
                  meal.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// Builds a summary card for the current day's training session.
  /// Synchronizes with [exerciseLookup] to show real-world exercise data.
  Widget _buildTodayTrainingCard(TrainingDay day, AppLocalizations l10n, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.blueAccent.withValues(alpha: isDarkMode ? 0.4 : 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWeekdayName(day.day, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.focus,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          ...day.exercises.map((ex) {
            final wgerData = widget.exerciseLookup[ex.exerciseId];

            return ExpansionTile(
              shape: const Border(),
              iconColor: Colors.blueAccent,
              title: Text(
                wgerData?.name ?? 'Unknown Exercise',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${ex.sets} x ${ex.reps}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wgerData != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (wgerData.mainMuscleId != null)
                              _buildMusclePreview(wgerData.mainMuscleId!, theme),
                            if (wgerData.exerciseImageUrl != null)
                              _buildExecutionPreview(wgerData.exerciseImageUrl!),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      Divider(height: 20, color: theme.dividerColor.withValues(alpha: 0.05)),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.rest}: ${ex.restSeconds}s',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ex.tips,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Helper widget to display a placeholder or anatomy information for a muscle group.
  Widget _buildMusclePreview(int id, ThemeData theme) {
    return Column(
      children: [
        const Text(
          'Anatomy',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: Text(
              'Muscle\n$id',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper widget to display the network image for the exercise execution.
  Widget _buildExecutionPreview(String url) {
    return Column(
      children: [
        const Text(
          'Execution',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image, size: 20, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}