import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/core/utils/date_time_extensions.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart';
import 'package:better_me/features/diets/presentation/widgets/diet_meal_tile.dart';

/// Screen responsible for displaying an already generated diet plan.
/// Refactored to use the AiDietPlan DTO, modern theme support, and the reusable DietMealTile.
class DietDetailScreen extends StatefulWidget {
  final Diet diet;
  final Profile profile;

  const DietDetailScreen({
    super.key,
    required this.diet,
    required this.profile,
  });

  @override
  State<DietDetailScreen> createState() => _DietDetailScreenState();
}

class _DietDetailScreenState extends State<DietDetailScreen> {
  AiDietPlan? _dietPlan;
  bool _hasError = false;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _loadSavedDiet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadSavedDiet() {
    try {
      final jsonString = widget.diet.generatedContent;
      if (jsonString == null || jsonString.isEmpty) {
        throw Exception('No generated content found.');
      }
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      setState(() {
        _dietPlan = AiDietPlan.fromJson(jsonMap);
      });
    } catch (e) {
      debugPrint('--- ERROR PARSING SAVED DIET --- $e');
      setState(() => _hasError = true);
    }
  }

  IconData _getObjectiveIcon() {
    switch (widget.diet.objective) {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.diet.name,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorGeneratingDiet,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_dietPlan == null || _dietPlan!.days.isEmpty) {
      return Center(child: Text(l10n.noDietData));
    }

    return Column(
      children: [
        _buildDashboardSummary(context, theme, l10n),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) => setState(() => _currentPage = index),
            itemCount: _dietPlan!.days.length,
            itemBuilder: (context, index) {
              return _buildDietDayCard(_dietPlan!.days[index], context, theme);
            },
          ),
        ),
        _buildPageIndicator(theme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDashboardSummary(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final hasAllergies = widget.diet.allergies?.isNotEmpty ?? false;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getObjectiveIcon(),
              size: 32,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.diet.objective.toUpperCase(),
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
                      l10n
                          .daysPerWeek(_dietPlan?.days.length ?? 0)
                          .replaceFirst('/', ' '),
                    ),
                    if (hasAllergies) ...[
                      const SizedBox(width: 16),
                      _buildQuickStat(
                        theme,
                        Icons.warning_amber_rounded,
                        l10n.dietAllergies,
                        color: Colors.redAccent,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    ThemeData theme,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final displayColor =
        color ??
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;
    return Row(
      children: [
        Icon(icon, size: 16, color: displayColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: displayColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDietDayCard(DietDay day, BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      day.day.toLocalizedWeekdayName(l10n),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${day.totalCalories} ${l10n.kcal}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: day.meals.length,
                separatorBuilder: (context, index) => Divider(
                  height: 48,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) => DietMealTile(
                  meal: day.meals[index],
                  idProfile: widget.profile.idProfile,
                  dietObjective: widget.diet.objective,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    if (_dietPlan == null || _dietPlan!.days.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _dietPlan!.days.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 6.0,
          width: _currentPage == index ? 24.0 : 6.0,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.orangeAccent
                : theme.dividerColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      ),
    );
  }
}
