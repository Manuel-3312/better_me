import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/core/utils/date_time_extensions.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/presentation/widgets/training_exercise_tile.dart';

/// Screen responsible for displaying an already generated training plan.
class TrainingDetailScreen extends StatefulWidget {
  final Training training;
  final Profile profile;

  const TrainingDetailScreen({
    super.key,
    required this.training,
    required this.profile,
  });

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();
  AiTrainingPlan? _trainingPlan;
  Map<int, WgerExercise> _exerciseLookup = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final allExercises = await _localDb.getAllExercises();
      _exerciseLookup = {for (var e in allExercises) e.id: e};

      final jsonString = widget.training.generatedContent;
      if (jsonString == null || jsonString.isEmpty) {
        throw Exception('No generated content found.');
      }
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      setState(() {
        _trainingPlan = AiTrainingPlan.fromJson(jsonMap);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('--- ERROR INITIALIZING TRAINING DATA --- $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _getObjectiveSvg() {
    switch (widget.training.objective) {
      case 'strength':
        return 'assets/icons/strength.svg';
      case 'endurance':
        return 'assets/icons/endurance.svg';
      default:
        return 'assets/icons/hypertrophy.svg';
    }
  }

  String _getLocalizedObjective(String objective, AppLocalizations l10n) {
    switch (objective) {
      case 'strength':
        return l10n.strength;
      case 'endurance':
        return l10n.endurance;
      default:
        return l10n.hypertrophy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color trainingColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.training.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: trainingColor))
          : _buildBody(context, theme, trainingColor, isDarkMode),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    Color trainingColor,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              l10n.errorGeneratingTraining,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_trainingPlan == null || _trainingPlan!.days.isEmpty) {
      return Center(child: Text(l10n.noTrainingData));
    }

    return DefaultTabController(
      length: _trainingPlan!.days.length,
      child: Column(
        children: [
          _buildDashboardSummary(context, theme, l10n, trainingColor),
          Container(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: trainingColor,
              labelColor: trainingColor,
              unselectedLabelColor: theme.hintColor,
              dividerColor: theme.dividerColor.withValues(alpha: 0.1),
              tabs: _trainingPlan!.days.map((day) {
                return Tab(text: day.day.toLocalizedWeekdayName(l10n));
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: _trainingPlan!.days.map((day) {
                return _buildDayView(
                  day,
                  context,
                  theme,
                  trainingColor,
                  isDarkMode,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Color trainingColor,
  ) {
    final localizedObjective = _getLocalizedObjective(
      widget.training.objective,
      l10n,
    );

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: trainingColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              _getObjectiveSvg(),
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(trainingColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedObjective.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuickStat(
                      theme,
                      Icons.calendar_month,
                      l10n.daysPerWeek(widget.training.maxDays),
                    ),
                    const SizedBox(width: 16),
                    _buildQuickStat(
                      theme,
                      Icons.timer,
                      '${widget.training.maxTime.toInt()} min',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDayView(
    TrainingDay day,
    BuildContext context,
    ThemeData theme,
    Color trainingColor,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.8,
                      ),
                      theme.colorScheme.surface.withValues(alpha: 0.9),
                    ]
                  : [trainingColor, trainingColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode
                ? Border.all(color: trainingColor.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.fitness_center,
                color: isDarkMode ? trainingColor : Colors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.day.toLocalizedWeekdayName(l10n).toUpperCase(),
                      style: TextStyle(
                        color: isDarkMode
                            ? theme.hintColor
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.focus,
                      style: TextStyle(
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...day.exercises.map((exercise) {
          final wgerData = _exerciseLookup[exercise.exerciseId];
          return TrainingExerciseTile(
            exercise: exercise,
            wgerData: wgerData,
            idProfile: widget.profile.idProfile,
            trainingObjective: widget.training.objective,
          );
        }),
      ],
    );
  }
}
