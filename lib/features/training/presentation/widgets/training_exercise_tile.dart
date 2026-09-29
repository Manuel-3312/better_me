import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/presentation/widgets/muscle_anatomy_widget.dart';
import 'package:better_me/features/training/data/favorite_exercises_repository.dart';
import 'package:better_me/features/training/domain/models/favorite_exercise.dart';

/// Reusable widget responsible for displaying a single training exercise.
/// Manages its own favorite state by interacting with the local repository.
class TrainingExerciseTile extends StatefulWidget {
  final TrainingExercise exercise;
  final WgerExercise? wgerData;
  final int? idProfile;
  final String? trainingObjective;

  const TrainingExerciseTile({
    super.key,
    required this.exercise,
    this.wgerData,
    this.idProfile,
    this.trainingObjective,
  });

  @override
  State<TrainingExerciseTile> createState() => _TrainingExerciseTileState();
}

class _TrainingExerciseTileState extends State<TrainingExerciseTile> {
  final FavoriteExercisesRepository _favoritesRepo = FavoriteExercisesRepository();
  bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.idProfile == null) {
      if (mounted) setState(() => _isLoadingFav = false);
      return;
    }
    final isFav = await _favoritesRepo.isFavorite(widget.idProfile!, widget.exercise.exerciseId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoadingFav = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.idProfile == null || widget.trainingObjective == null) return;

    final previousState = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        final newFavorite = FavoriteExercise(
          idProfile: widget.idProfile!,
          trainingObjective: widget.trainingObjective!,
          exercise: widget.exercise,
        );
        await _favoritesRepo.addFavorite(newFavorite);
      } else {
        await _favoritesRepo.removeFavorite(widget.idProfile!, widget.exercise.exerciseId);
      }
    } catch (e) {
      setState(() => _isFavorite = previousState);
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color trainingColor = isDarkMode ? theme.colorScheme.primary : Colors.blueAccent;
    final String exerciseName = widget.wgerData?.name ?? 'Unknown Exercise';

    return ExpansionTile(
      shape: const Border(),
      iconColor: trainingColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              exerciseName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          if (widget.idProfile != null && widget.trainingObjective != null && !_isLoadingFav)
            GestureDetector(
              onTap: _toggleFavorite,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  key: ValueKey<bool>(_isFavorite),
                  color: trainingColor,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${widget.exercise.sets} x ${widget.exercise.reps}',
        style: TextStyle(
          fontSize: 12,
          color: trainingColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.wgerData != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.wgerData!.mainMuscleId != null)
                      MuscleAnatomyWidget(
                        primaryMuscleId: widget.wgerData!.mainMuscleId!,
                        secondaryMuscleIds: widget.wgerData!.secondaryMuscleIds,
                        isFront: _isFrontMuscle(widget.wgerData!.mainMuscleId!),
                        highlightColor: trainingColor,
                      ),
                    if (widget.wgerData!.exerciseImageUrl != null)
                      _buildExecutionPreview(widget.wgerData!.exerciseImageUrl!),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Divider(
                height: 20,
                color: theme.dividerColor.withValues(alpha: 0.05),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: trainingColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.rest}: ${widget.exercise.restSeconds}s',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.exercise.tips,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isFrontMuscle(int muscleId) {
    const frontMuscles = [1, 2, 3, 4, 6, 10, 13, 14];
    return frontMuscles.contains(muscleId);
  }

  Widget _buildExecutionPreview(String url) {
    return Column(
      children: [
        const Text(
          'EXECUTION',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 20, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}