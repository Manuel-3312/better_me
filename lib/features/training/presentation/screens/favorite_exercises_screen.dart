import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/domain/models/favorite_exercise.dart';
import 'package:better_me/features/training/data/favorite_exercises_repository.dart';
import 'package:better_me/features/training/presentation/widgets/training_exercise_tile.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Screen displaying the user's saved favorite exercises.
/// Groups exercises by their training objective and provides a toggle for AI integration.
class FavoriteExercisesScreen extends StatefulWidget {
  final Profile profile;

  const FavoriteExercisesScreen({super.key, required this.profile});

  @override
  State<FavoriteExercisesScreen> createState() =>
      _FavoriteExercisesScreenState();
}

class _FavoriteExercisesScreenState extends State<FavoriteExercisesScreen> {
  final FavoriteExercisesRepository _favoritesRepo =
      FavoriteExercisesRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();

  Map<String, List<FavoriteExercise>> _groupedFavorites = {};
  Map<int, WgerExercise> _exerciseLookup = {};

  bool _isLoading = true;
  bool _useFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.profile.idProfile == null) return;

    final includeFavs = await _favoritesRepo.getIncludeFavoritesPreference();
    final favs = await _favoritesRepo.getFavorites(widget.profile.idProfile!);

    final allExercises = await _localDb.getAllExercises();
    final lookup = {for (var e in allExercises) e.id: e};

    final grouped = <String, List<FavoriteExercise>>{};
    for (var fav in favs) {
      grouped.putIfAbsent(fav.trainingObjective, () => []).add(fav);
    }

    if (mounted) {
      setState(() {
        _useFavorites = includeFavs;
        _groupedFavorites = grouped;
        _exerciseLookup = lookup;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePreference(bool value) async {
    setState(() => _useFavorites = value);
    await _favoritesRepo.setIncludeFavoritesPreference(value);
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

  String _getObjectiveSvg(String objective) {
    switch (objective) {
      case 'strength':
        return 'assets/icons/strength.svg';
      case 'endurance':
        return 'assets/icons/endurance.svg';
      default:
        return 'assets/icons/hypertrophy.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color trainingColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.favoriteExercisesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: trainingColor))
          : Column(
              children: [
                SwitchListTile(
                  title: Text(
                    l10n.includeInAiPlans,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.aiPrioritizeDesc),
                  value: _useFavorites,
                  activeThumbColor: trainingColor,
                  onChanged: _togglePreference,
                ),
                Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                Expanded(
                  child: _groupedFavorites.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: theme.hintColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noFavoritesMessage,
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _groupedFavorites.keys.length,
                          itemBuilder: (context, index) {
                            final objective = _groupedFavorites.keys.elementAt(
                              index,
                            );
                            final exercises = _groupedFavorites[objective]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildObjectiveHeader(
                                  objective,
                                  l10n,
                                  trainingColor,
                                ),
                                ...exercises.map((fav) {
                                  final wgerData =
                                      _exerciseLookup[fav.exercise.exerciseId];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Card(
                                      elevation: 0,
                                      color: theme.cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: theme.dividerColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: TrainingExerciseTile(
                                        exercise: fav.exercise,
                                        wgerData: wgerData,
                                        idProfile: widget.profile.idProfile,
                                        trainingObjective:
                                            fav.trainingObjective,
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildObjectiveHeader(
    String objective,
    AppLocalizations l10n,
    Color color,
  ) {
    final localized = _getLocalizedObjective(objective, l10n);
    final svgPath = _getObjectiveSvg(objective);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0, left: 4.0),
      child: Row(
        children: [
          SvgPicture.asset(
            svgPath,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            localized.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
