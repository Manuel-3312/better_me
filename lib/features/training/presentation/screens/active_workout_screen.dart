import 'dart:async';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/presentation/widgets/muscle_anatomy_widget.dart';
import 'workout_complete_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Training training;
  final TrainingDay trainingDay;
  final Map<int, WgerExercise> exerciseLookup;
  final String localizedDayName;

  const ActiveWorkoutScreen({
    super.key,
    required this.training,
    required this.trainingDay,
    required this.exerciseLookup,
    required this.localizedDayName,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 1;
  bool _isResting = false;

  Timer? _restTimer;
  int _remainingRestSeconds = 0;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRest() {
    final currentExercise = widget.trainingDay.exercises[_currentExerciseIndex];
    setState(() {
      _isResting = true;
      _remainingRestSeconds = currentExercise.restSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRestSeconds > 0) {
        setState(() {
          _remainingRestSeconds--;
        });
      } else {
        _skipRestOrNext();
      }
    });
  }

  void _skipRestOrNext() {
    _restTimer?.cancel();
    final currentExercise = widget.trainingDay.exercises[_currentExerciseIndex];

    if (_currentSetIndex < currentExercise.sets) {
      setState(() {
        _currentSetIndex++;
        _isResting = false;
      });
    } else {
      if (_currentExerciseIndex < widget.trainingDay.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 1;
          _isResting = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutCompleteScreen(
              localizedDayName: widget.localizedDayName,
            ),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.stopWorkoutConfirm,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.no,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.yes,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool _isFrontMuscle(int muscleId) {
    const frontMuscles = [1, 2, 3, 4, 6, 10, 13, 14];
    return frontMuscles.contains(muscleId);
  }

  String _cleanHtml(String htmlString) {
    RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, theme, isDarkMode),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: _isResting
                      ? _buildRestView(context, theme, isDarkMode)
                      : _buildExerciseView(context, theme, isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    final totalExercises = widget.trainingDay.exercises.length;
    final progress = (_currentExerciseIndex) / totalExercises;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.training.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.localizedDayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentExerciseIndex + 1} / $totalExercises',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress == 0 ? 0.05 : progress,
              minHeight: 6,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    String text,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = widget.trainingDay.exercises[_currentExerciseIndex];
    final wgerData = widget.exerciseLookup[exercise.exerciseId];
    final String exerciseName = wgerData?.name ?? l10n.unknownExercise;

    return Padding(
      key: ValueKey('ExerciseView_$_currentExerciseIndex'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  Text(
                    exerciseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoPill(
                        '${l10n.setLabel} $_currentSetIndex/${exercise.sets}',
                        Icons.layers_rounded,
                        Colors.blueAccent,
                        theme,
                        isDarkMode,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoPill(
                        'x${exercise.reps}',
                        Icons.repeat_rounded,
                        Colors.orangeAccent,
                        theme,
                        isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: wgerData?.exerciseImageUrl != null
                              ? Image.network(
                                  wgerData!.exerciseImageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.fitness_center,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.fitness_center,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                        ),
                      ),

                      if (wgerData?.mainMuscleId != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: MuscleAnatomyWidget(
                              primaryMuscleId: wgerData!.mainMuscleId!,
                              secondaryMuscleIds: wgerData.secondaryMuscleIds,
                              isFront: _isFrontMuscle(wgerData.mainMuscleId!),
                              highlightColor: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3)
                          : theme.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ExpansionTile(
                        iconColor: Colors.blueAccent,
                        collapsedIconColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        title: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blueAccent,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.exerciseDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          if (wgerData?.description != null &&
                              wgerData!.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20.0,
                                0.0,
                                20.0,
                                16.0,
                              ),
                              child: Text(
                                _cleanHtml(wgerData.description),
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          if (exercise.tips.isNotEmpty) ...[
                            Divider(
                              height: 1,
                              color: theme.dividerColor.withValues(alpha: 0.1),
                            ),
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.05),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Colors.amber,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      exercise.tips,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        height: 1.5,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startRest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 4,
                      shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      l10n.restAction.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () async {
                    final pop = await _onWillPop();
                    if (pop && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.stop_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestView(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final l10n = AppLocalizations.of(context)!;

    String nextExerciseName = l10n.unknownExercise;
    if (_currentSetIndex <
        widget.trainingDay.exercises[_currentExerciseIndex].sets) {
      final wgerData =
          widget.exerciseLookup[widget
              .trainingDay
              .exercises[_currentExerciseIndex]
              .exerciseId];
      nextExerciseName = wgerData?.name ?? l10n.unknownExercise;
    } else if (_currentExerciseIndex <
        widget.trainingDay.exercises.length - 1) {
      final nextExercise =
          widget.trainingDay.exercises[_currentExerciseIndex + 1];
      final wgerData = widget.exerciseLookup[nextExercise.exerciseId];
      nextExerciseName = wgerData?.name ?? l10n.unknownExercise;
    } else {
      nextExerciseName = l10n.workoutCompletedTitle;
    }

    return Padding(
      key: const ValueKey('RestView'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value:
                        _remainingRestSeconds /
                        widget
                            .trainingDay
                            .exercises[_currentExerciseIndex]
                            .restSeconds,
                    strokeWidth: 8,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.restTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_remainingRestSeconds),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    )
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.nextExerciseLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nextExerciseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ElevatedButton(
              onPressed: _skipRestOrNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: theme.colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                l10n.skipRestAction.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
