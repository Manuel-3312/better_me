import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'coockbook_screen.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';
import 'package:better_me/features/diets/domain/utils/diet_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';
import 'package:better_me/features/diets/data/favorite_meals_repository.dart';
import 'package:better_me/features/diets/domain/models/favorite_meal.dart';
import 'create_diet_screen.dart';
import 'package:better_me/features/diets/presentation/screens/diet_detail_screen.dart';

class DietsScreen extends StatefulWidget {
  final Profile profile;

  const DietsScreen({super.key, required this.profile});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  final DietRepository _repository = DietRepository();
  late final GeminiService _geminiService;

  List<Diet> _diets = [];
  bool _isLoadingDiets = true;
  String? _error;

  Diet? _pendingDiet;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _loadDiets();
  }

  Future<void> _loadDiets() async {
    if (widget.profile.idProfile == null) return;

    setState(() {
      _isLoadingDiets = true;
      _error = null;
    });

    try {
      final diets = await _repository.getDietsByProfile(
        widget.profile.idProfile!,
      );
      if (mounted) {
        setState(() {
          _diets = diets;
          _isLoadingDiets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingDiets = false;
        });
      }
    }
  }

  Future<void> _generateDietInBackground(Diet preliminaryDiet) async {
    setState(() => _pendingDiet = preliminaryDiet);
    final l10n = AppLocalizations.of(context)!;

    try {
      final locale = Localizations.localeOf(context).languageCode;
      final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

      final favRepo = FavoriteMealsRepository();
      final includeFavs = await favRepo.getIncludeFavoritesPreference();

      List<FavoriteMeal> targetFavorites = [];
      if (includeFavs) {
        targetFavorites = await favRepo.getFavorites(
          preliminaryDiet.idProfile,
          objective: preliminaryDiet.objective,
        );
      }

      final prompt = DietPromptBuilder.buildDietPrompt(
        widget.profile,
        preliminaryDiet,
        language: languageInstruction,
        favoriteMeals: targetFavorites,
      );

      final responseText = await _geminiService.generateContent(prompt);
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty AI response');
      }

      final cleanJsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      AiDietPlan.fromJson(jsonMap);

      final finalDiet = Diet(
        idProfile: preliminaryDiet.idProfile,
        name: preliminaryDiet.name,
        objective: preliminaryDiet.objective,
        allergies: preliminaryDiet.allergies,
        additionalData: preliminaryDiet.additionalData,
        generatedContent: cleanJsonString,
      );

      await _repository.createDiet(finalDiet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dietCreatedSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating diet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneratingDiet),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pendingDiet = null);
        _loadDiets();
      }
    }
  }

  Future<void> _confirmAndDeleteDiet(Diet diet, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Diet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this diet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _diets.removeAt(index);
    });

    if (!mounted) return;

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${diet.name} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.orangeAccent,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final reason = await controller.closed;

    if (reason == SnackBarClosedReason.action) {
      if (mounted) {
        setState(() {
          _diets.insert(index, diet);
        });
      }
    } else {
      if (diet.idDiet != null) {
        try {
          await _repository.deleteDiet(diet.idDiet!);
        } catch (e) {
          debugPrint('Error deleting diet from database: $e');
        }
      }
    }
  }

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

  IconData _getObjectiveIcon(String objective) {
    switch (objective) {
      case 'weightLoss':
        return Icons.trending_down;
      case 'muscleGain':
        return Icons.trending_up;
      case 'maintenance':
      default:
        return Icons.trending_flat;
    }
  }

  Widget _buildDietCard(
    Diet diet,
    int index,
    ThemeData theme,
    AppLocalizations l10n, {
    bool isPending = false,
  }) {
    final Color dietColor = Colors.orangeAccent;
    final String localizedObjective = _getLocalizedObjective(
      diet.objective,
      l10n,
    );
    final IconData objectiveIcon = _getObjectiveIcon(diet.objective);

    final card = Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: 12,
          right: 8,
          top: 12,
          bottom: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: dietColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(objectiveIcon, color: dietColor, size: 28),
        ),
        title: Text(
          diet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            isPending
                ? '$localizedObjective • ${l10n.cookingAiPlan}'
                : localizedObjective,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        trailing: isPending
            ? const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.orangeAccent,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent.withValues(alpha: 0.8),
                    ),
                    onPressed: () => _confirmAndDeleteDiet(diet, index),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        onTap: isPending
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DietDetailScreen(diet: diet, profile: widget.profile),
                  ),
                );
              },
      ),
    );

    if (isPending) {
      return Opacity(opacity: 0.5, child: AbsorbPointer(child: card));
    }
    return card;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const Color dietColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.dietsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            color: Colors.orangeAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CookbookScreen(profile: widget.profile),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBodyContent(theme, l10n, dietColor),
      floatingActionButton: Opacity(
        opacity: _pendingDiet != null ? 0.5 : 1.0,
        child: AbsorbPointer(
          absorbing: _pendingDiet != null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                        theme.colorScheme.surface.withValues(alpha: 0.9),
                      ]
                    : [dietColor, dietColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: isDarkMode
                  ? Border.all(color: dietColor.withValues(alpha: 0.3))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: dietColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final Diet? preliminaryDiet = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateDietScreen(profile: widget.profile),
                    ),
                  );

                  if (preliminaryDiet != null) {
                    _generateDietInBackground(preliminaryDiet);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: isDarkMode ? dietColor : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.createDiet,
                        style: TextStyle(
                          color: isDarkMode ? dietColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    ThemeData theme,
    AppLocalizations l10n,
    Color dietColor,
  ) {
    if (_isLoadingDiets && _pendingDiet == null) {
      return Center(child: CircularProgressIndicator(color: dietColor));
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_diets.isEmpty && _pendingDiet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDietsMessage,
              style: TextStyle(fontSize: 16, color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    final int itemCount = _diets.length + (_pendingDiet != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_pendingDiet != null && index == 0) {
          return _buildDietCard(
            _pendingDiet!,
            -1,
            theme,
            l10n,
            isPending: true,
          );
        }

        final targetIndex = _pendingDiet != null ? index - 1 : index;
        return _buildDietCard(
          _diets[targetIndex],
          targetIndex,
          theme,
          l10n,
          isPending: false,
        );
      },
    );
  }
}
