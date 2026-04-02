import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';
import 'package:better_me/features/diets/domain/models/favorite_meal.dart';
import 'package:better_me/features/diets/data/favorite_meals_repository.dart';

/// Reusable widget displaying a single diet meal with expandable details.
/// Manages its own favorite state by interacting with the local repository.
class DietMealTile extends StatefulWidget {
  final DietMeal meal;
  final int? idProfile;
  final String? dietObjective;

  const DietMealTile({
    super.key,
    required this.meal,
    this.idProfile,
    this.dietObjective,
  });

  @override
  State<DietMealTile> createState() => _DietMealTileState();
}

class _DietMealTileState extends State<DietMealTile> {
  final FavoriteMealsRepository _favoritesRepo = FavoriteMealsRepository();
  bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.idProfile == null) {
      setState(() => _isLoadingFav = false);
      return;
    }
    final isFav = await _favoritesRepo.isFavorite(widget.idProfile!, widget.meal.name);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoadingFav = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.idProfile == null || widget.dietObjective == null) return;

    final previousState = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        final newFavorite = FavoriteMeal(
          idProfile: widget.idProfile!,
          dietObjective: widget.dietObjective!,
          meal: widget.meal,
        );
        await _favoritesRepo.addFavorite(newFavorite);
      } else {
        await _favoritesRepo.removeFavorite(widget.idProfile!, widget.meal.name);
      }
    } catch (e) {
      setState(() => _isFavorite = previousState);
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.meal.type.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.hintColor,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                Text(
                  '${widget.meal.calories} ${l10n.kcal}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                if (widget.idProfile != null && widget.dietObjective != null && !_isLoadingFav) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        key: ValueKey<bool>(_isFavorite),
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        subtitle: Text(
          widget.meal.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 16.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.meal.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.restaurant,
                        label: "Recipe",
                        onPressed: () => _showRecipeDialog(context),
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.pie_chart,
                        label: "Macros",
                        onPressed: () => _showMacrosDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
        foregroundColor: Colors.orangeAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.meal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DialogSectionTitle(title: "Ingredients"),
                ...widget.meal.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("• $ing", style: const TextStyle(fontSize: 14)),
                )),
                const SizedBox(height: 20),
                const _DialogSectionTitle(title: "Preparation"),
                ...widget.meal.preparationSteps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text("${entry.key + 1}. ${entry.value}",
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  void _showMacrosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Macronutrients", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMacroRow("Proteins", "${widget.meal.macros.protein}g", Colors.redAccent),
            _buildMacroRow("Carbohydrates", "${widget.meal.macros.carbs}g", Colors.blueAccent),
            _buildMacroRow("Fats", "${widget.meal.macros.fats}g", Colors.orangeAccent),
            const Divider(height: 30),
            Text("Total: ${widget.meal.calories} kcal", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(label),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DialogSectionTitle extends StatelessWidget {
  final String title;
  const _DialogSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent, letterSpacing: 1),
      ),
    );
  }
}