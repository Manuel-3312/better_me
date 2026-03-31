import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

// Absolute imports
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/training_plan.dart';

/// Screen responsible for displaying an already generated training plan.
/// Features a night-mode optimized UI with deep gradients and high-precision colors.
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
  TrainingPlan? _trainingPlan;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTraining();
  }

  /// Parses the AI-generated JSON content from the local database.
  void _loadSavedTraining() {
    try {
      final jsonString = widget.training.generatedContent;
      if (jsonString == null || jsonString.isEmpty) {
        throw Exception('No generated content found.');
      }
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      setState(() {
        _trainingPlan = TrainingPlan.fromJson(jsonMap);
      });
    } catch (e) {
      debugPrint('--- ERROR PARSING SAVED TRAINING --- $e');
      setState(() => _hasError = true);
    }
  }

  String _getObjectiveSvg() {
    switch (widget.training.objective) {
      case 'strength': return 'assets/icons/strength.svg';
      case 'endurance': return 'assets/icons/endurance.svg';
      default: return 'assets/icons/hypertrophy.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(l10n.errorGeneratingTraining, style: const TextStyle(fontSize: 16)),
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
          _buildDashboardSummary(context, theme),

          // Adaptive TabBar
          Container(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.hintColor,
              dividerColor: theme.dividerColor.withValues(alpha: 0.1),
              tabs: _trainingPlan!.days.map((day) {
                return Tab(text: _getWeekdayName(day.dayNumber, l10n));
              }).toList(),
            ),
          ),

          Expanded(
            child: TabBarView(
              children: _trainingPlan!.days.map((day) {
                return _buildDayView(day, context, theme);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              _getObjectiveSvg(),
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.training.objective.toUpperCase(),
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
                    _buildQuickStat(theme, Icons.calendar_month, '${widget.training.maxDays} days/wk'),
                    const SizedBox(width: 16),
                    _buildQuickStat(theme, Icons.timer, '${widget.training.maxTime.toInt()} min'),
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
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Builds the view for a single day.
  /// The Day Banner is now significantly darker in Night Mode for better integration.
  Widget _buildDayView(TrainingDay day, BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Optimized Day Banner
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                theme.colorScheme.surface.withValues(alpha: 0.9),
              ]
                  : [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode
                ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                : null,
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                  Icons.fitness_center,
                  color: isDarkMode ? theme.colorScheme.primary : Colors.white,
                  size: 28
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWeekdayName(day.dayNumber, l10n).toUpperCase(),
                      style: TextStyle(
                        color: isDarkMode ? theme.hintColor : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.focus,
                      style: TextStyle(
                        color: isDarkMode ? theme.colorScheme.onSurface : Colors.white,
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
        ...day.exercises.map((exercise) => _buildExerciseAccordion(exercise, l10n, theme)),
      ],
    );
  }

  Widget _buildExerciseAccordion(Exercise exercise, AppLocalizations l10n, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _buildStatBadge(theme, Icons.reorder, '${exercise.sets} ${l10n.sets} x ${exercise.reps}'),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.rest}: ${exercise.restSeconds} ${l10n.seconds}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

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
}