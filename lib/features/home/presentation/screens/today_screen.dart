import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/core/utils/date_time_extensions.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';
import 'package:better_me/features/diets/presentation/widgets/diet_meal_tile.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/presentation/widgets/training_exercise_tile.dart';
import 'package:better_me/features/home/presentation/controllers/today_controller.dart';

/// Screen responsible for displaying the user's active fitness and nutrition plans for the current day.
class TodayScreen extends StatefulWidget {
  final Profile profile;
  final List<Diet> availableDiets;
  final List<Training> availableTrainings;
  final Map<int, WgerExercise> exerciseLookup;
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
  late final TodayController _controller;

  bool _isDietExpanded = false;
  bool _isTrainingExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TodayController();
    _controller.initialize(
      widget.profile,
      widget.availableDiets,
      widget.availableTrainings,
    );
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.availableTrainings != widget.availableTrainings ||
        oldWidget.availableDiets != widget.availableDiets) {
      _controller.updateData(
        widget.profile,
        widget.availableDiets,
        widget.availableTrainings,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _controller.isConfiguring ? l10n.setupPlanTitle : l10n.todayTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (!_controller.isConfiguring)
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _controller.setConfiguring(true),
                ),
            ],
          ),
          body: (widget.isLoading || _controller.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : _controller.isConfiguring
              ? _buildConfigurationView(l10n, theme)
              : _buildDashboardView(l10n, theme),
        );
      },
    );
  }

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
            initialValue: _controller.activeDiet,
            decoration: InputDecoration(
              labelText: l10n.activeDiet,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: widget.availableDiets
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (v) => _controller.setActiveDiet(v),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<Training>(
            initialValue: _controller.activeTraining,
            decoration: InputDecoration(
              labelText: l10n.activeTraining,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: widget.availableTrainings
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => _controller.setActiveTraining(v),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed:
                (_controller.activeDiet != null &&
                    _controller.activeTraining != null)
                ? _controller.saveConfiguration
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  Widget _buildDashboardView(AppLocalizations l10n, ThemeData theme) {
    AiDietPlan? dietPlan;
    if (_controller.activeDiet?.generatedContent != null) {
      dietPlan = AiDietPlan.fromJson(
        jsonDecode(_controller.activeDiet!.generatedContent!),
      );
    }

    AiTrainingPlan? trainingPlan;
    if (_controller.activeTraining?.generatedContent != null) {
      trainingPlan = AiTrainingPlan.fromJson(
        jsonDecode(_controller.activeTraining!.generatedContent!),
      );
    }

    final int currentWeekday = DateTime.now().weekday;

    DietDay? dDay;
    if (dietPlan?.days.isNotEmpty == true) {
      try {
        dDay = dietPlan!.days.firstWhere((d) => d.day == currentWeekday);
      } catch (_) {
        dDay = dietPlan!.days[(currentWeekday - 1) % dietPlan.days.length];
      }
    }

    TrainingDay? tDay;
    if (trainingPlan?.days.isNotEmpty == true) {
      try {
        tDay = trainingPlan!.days.firstWhere((d) => d.day == currentWeekday);
      } catch (_) {
        tDay = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildExpandableSection(
          title: l10n.yourMeals,
          icon: Icons.restaurant_menu,
          color: Colors.orangeAccent,
          isExpanded: _isDietExpanded,
          onTap: () => setState(() => _isDietExpanded = !_isDietExpanded),
          child: dDay != null
              ? _buildTodayDietCard(dDay, l10n, theme)
              : Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                  child: Text(l10n.noDietDataForToday),
                ),
        ),
        const SizedBox(height: 24),
        _buildExpandableSection(
          title: l10n.yourTraining,
          icon: Icons.fitness_center,
          color: Colors.blueAccent,
          isExpanded: _isTrainingExpanded,
          onTap: () =>
              setState(() => _isTrainingExpanded = !_isTrainingExpanded),
          child: tDay != null
              ? _buildTodayTrainingCard(tDay, l10n, theme)
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildRestDayCard(l10n, theme),
                ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: child,
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }

  Widget _buildTodayDietCard(
    DietDay day,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
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
              day.day.toLocalizedWeekdayName(l10n),
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: day.meals.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;
                return Column(
                  children: [
                    DietMealTile(
                      meal: meal,
                      idProfile: widget.profile.idProfile,
                      dietObjective: _controller.activeDiet?.objective,
                    ),
                    if (index < day.meals.length - 1)
                      Divider(
                        height: 32,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTrainingCard(
    TrainingDay day,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
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
                  day.day.toLocalizedWeekdayName(l10n),
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
            return TrainingExerciseTile(
              exercise: ex,
              wgerData: wgerData,
              idProfile: widget.profile.idProfile,
              trainingObjective: _controller.activeTraining?.objective,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(AppLocalizations l10n, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
      color: isDarkMode
          ? Colors.teal.withValues(alpha: 0.1)
          : Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.teal.withValues(alpha: isDarkMode ? 0.4 : 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.self_improvement, size: 48, color: Colors.teal.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.restDayTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.restDayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
