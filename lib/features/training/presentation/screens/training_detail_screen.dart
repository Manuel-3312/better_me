import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/training/presentation/widgets/muscle_anatomy_widget.dart';
import 'package:better_me/features/profile/data/cloud_sync_service.dart';

class TrainingDetailScreen extends StatefulWidget {
  final Training training;

  const TrainingDetailScreen({super.key, required this.training});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  final TrainingRepository _repository = TrainingRepository();
  AiTrainingPlan? _aiPlan;
  Map<int, WgerExercise> _catalogMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.training.generatedContent != null) {
        final jsonMap = jsonDecode(widget.training.generatedContent!);
        _aiPlan = AiTrainingPlan.fromJson(jsonMap);
      }
      final localDb = ExerciseLocalDatabase();
      final catalog = await localDb.getAllExercises();
      _catalogMap = {for (var e in catalog) e.id: e};
    } catch (e) {
      debugPrint('Error loading training detail: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReorderedPlan() async {
    if (_aiPlan != null && widget.training.idTraining != null) {
      try {
        final updatedJson = jsonEncode(_aiPlan!.toJson());
        final updatedTraining = Training(
          idTraining: widget.training.idTraining,
          idProfile: widget.training.idProfile,
          name: widget.training.name,
          objective: widget.training.objective,
          maxDays: widget.training.maxDays,
          maxTime: widget.training.maxTime,
          generatedContent: updatedJson,
        );
        await _repository.saveFullAiTrainingPlan(updatedTraining, _aiPlan!);
        CloudSyncService().backupPlansToCloud().catchError((e) {
          debugPrint('Error uploading reorder to Supabase: $e');
        });
      } catch (e) {
        debugPrint('Error saving reordered plan: $e');
      }
    }
  }

  bool _isFrontMuscle(int? muscleId) {
    if (muscleId == null) return true;
    // IDs de Wger correspondientes a la parte delantera del cuerpo
    const frontMuscles = [1, 2, 3, 4, 6, 10, 13, 14];
    return frontMuscles.contains(muscleId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_aiPlan == null || _aiPlan!.days.isEmpty) return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.noTrainingData)));

    final trainingDays = _aiPlan!.days;

    return DefaultTabController(
      length: trainingDays.length,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderBackground(theme),
                  collapseMode: CollapseMode.pin,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Container(
                    width: double.infinity,
                    color: theme.scaffoldBackgroundColor,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.colorScheme.primary,
                      tabs: trainingDays.map((day) => _buildDayTab(day, context)).toList(),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: trainingDays.map((day) => _buildDayView(day, theme, l10n)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(TrainingDay day, BuildContext context) {
    // Obtenemos el idioma actual de la app
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final dayLabel = isSpanish ? 'DÍA' : 'DAY';

    return Tab(
      child: SizedBox(
        width: 80,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            Text(
              '${day.day}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.colorScheme.primary.withValues(alpha: 0.08), theme.scaffoldBackgroundColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              widget.training.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderChip(theme, Icons.fitness_center_rounded, widget.training.objective.toUpperCase()),
              _buildHeaderChip(theme, Icons.timer_outlined, '${widget.training.maxTime.toInt()} min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildDayView(TrainingDay day, ThemeData theme, AppLocalizations l10n) {
    final exercises = day.exercises;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Icon(Icons.track_changes_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day.focus.toUpperCase(),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: exercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = exercises.removeAt(oldIndex);
                exercises.insert(newIndex, item);
                _saveReorderedPlan();
              });
            },
            itemBuilder: (context, index) => _buildExerciseCard(context, theme, exercises[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, ThemeData theme, TrainingExercise exercise, int index) {
    final wgerMatch = _catalogMap[exercise.exerciseId];
    return Card(
      key: ValueKey('${exercise.exerciseId}_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showExerciseDetails(context, exercise, wgerMatch, theme),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: (wgerMatch?.exerciseImageUrl != null)
                    ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.network(
                      wgerMatch!.exerciseImageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(Icons.fitness_center, color: theme.colorScheme.primary)
                  ),
                )
                    : Icon(Icons.fitness_center, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wgerMatch?.name ?? 'Ejercicio', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildMiniBadge(theme, Icons.layers_rounded, '${exercise.sets}x${exercise.reps}'),
                        const SizedBox(width: 8),
                        _buildMiniBadge(theme, Icons.timer_outlined, '${exercise.restSeconds}s'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.drag_indicator_rounded, color: theme.hintColor.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, TrainingExercise exercise, WgerExercise? wgerMatch, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, // Ligeramente más grande al inicio
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              if (wgerMatch?.exerciseImageUrl != null)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                      wgerMatch!.exerciseImageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox()
                  ),
                ),
              const SizedBox(height: 24),
              Text(wgerMatch?.name ?? 'Ejercicio', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Text(wgerMatch?.description.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? exercise.tips, style: const TextStyle(fontSize: 16, height: 1.6)),
              const SizedBox(height: 32),

              // Aquí hemos metido la Anatomía entre las dos pastillas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildDetailBadge(theme, Icons.repeat, '${exercise.sets}x${exercise.reps}')),

                  if (wgerMatch?.mainMuscleId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MuscleAnatomyWidget(
                        primaryMuscleId: wgerMatch!.mainMuscleId!,
                        secondaryMuscleIds: wgerMatch.secondaryMuscleIds,
                        isFront: _isFrontMuscle(wgerMatch.mainMuscleId),
                        highlightColor: theme.colorScheme.primary,
                        size: 90, // Un poco más grande para que destaque bien
                      ),
                    ),

                  Expanded(child: _buildDetailBadge(theme, Icons.timer_outlined, '${exercise.restSeconds}s')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}