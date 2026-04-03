import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/favorite_meal.dart';
import 'package:better_me/features/diets/data/favorite_meals_repository.dart';
import 'package:better_me/features/diets/presentation/widgets/diet_meal_tile.dart';

/// Screen responsible for displaying the user's saved favorite meals.
///
/// Meals are grouped by their original diet objective, and the screen provides
/// a global toggle to allow the AI to prioritize these meals in future generations.
class CookbookScreen extends StatefulWidget {
  final Profile profile;

  const CookbookScreen({super.key, required this.profile});

  @override
  State<CookbookScreen> createState() => _CookbookScreenState();
}

class _CookbookScreenState extends State<CookbookScreen> {
  final FavoriteMealsRepository _favoritesRepo = FavoriteMealsRepository();
  Map<String, List<FavoriteMeal>> _groupedFavorites = {};
  bool _isLoading = true;
  bool _useFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Fetches favorite meals and preferences from the repository.
  Future<void> _loadData() async {
    if (widget.profile.idProfile == null) return;

    final includeFavs = await _favoritesRepo.getIncludeFavoritesPreference();
    final favs = await _favoritesRepo.getFavorites(widget.profile.idProfile!);

    final grouped = <String, List<FavoriteMeal>>{};
    for (var fav in favs) {
      grouped.putIfAbsent(fav.dietObjective, () => []).add(fav);
    }

    if (mounted) {
      setState(() {
        _useFavorites = includeFavs;
        _groupedFavorites = grouped;
        _isLoading = false;
      });
    }
  }

  /// Updates the global AI priority preference for favorite meals.
  Future<void> _togglePreference(bool value) async {
    setState(() => _useFavorites = value);
    await _favoritesRepo.setIncludeFavoritesPreference(value);
  }

  /// Helper to get the localized string for a diet objective.
  String _getLocalizedObjective(String objective, AppLocalizations l10n) {
    switch (objective) {
      case 'weightLoss':
        return l10n.weightLoss;
      case 'maintenance':
        return l10n.maintenance;
      case 'muscleGain':
        return l10n.muscleGain;
      default:
        return objective;
    }
  }

  /// Helper to get the icon representation for a diet objective.
  IconData _getObjectiveIcon(String objective) {
    switch (objective) {
      case 'weightLoss':
        return Icons.trending_down;
      case 'muscleGain':
        return Icons.trending_up;
      default:
        return Icons.trending_flat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.cookbookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : Column(
              children: [
                SwitchListTile(
                  title: Text(
                    l10n.includeInAiDiets,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.aiPrioritizeMealsDesc),
                  value: _useFavorites,
                  activeThumbColor: Colors.orangeAccent,
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
                                Icons.menu_book,
                                size: 80,
                                color: theme.hintColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cookbookEmpty,
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
                            final meals = _groupedFavorites[objective]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildObjectiveHeader(objective, l10n),
                                ...meals.map(
                                  (fav) => Padding(
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: DietMealTile(
                                          meal: fav.meal,
                                          idProfile: widget.profile.idProfile,
                                          dietObjective: fav.dietObjective,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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

  /// Builds a header section for each diet objective group.
  Widget _buildObjectiveHeader(String objective, AppLocalizations l10n) {
    final localized = _getLocalizedObjective(objective, l10n);
    final icon = _getObjectiveIcon(objective);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            localized.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
