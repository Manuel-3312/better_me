import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/presentation/controllers/diets_controller.dart';
import 'package:better_me/features/diets/presentation/screens/diet_detail_screen.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';
import 'coockbook_screen.dart';
import 'create_diet_screen.dart';

/// Primary interface for displaying and managing the user's dietary plans.
class DietsScreen extends StatefulWidget {
  final Profile profile;

  const DietsScreen({super.key, required this.profile});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  late final DietsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DietsController();
    if (widget.profile.idProfile != null) {
      _controller.loadDiets(widget.profile.idProfile!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDietCreation(Diet preliminaryDiet) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

    await _controller.generateDietInBackground(
      preliminaryDiet: preliminaryDiet,
      profile: widget.profile,
      languageInstruction: languageInstruction,
      onSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dietCreatedSuccess),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      },
      onError: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorGeneratingDiet),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }

  Future<void> _confirmAndDeleteDiet(Diet diet, int index) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: 'Delete Diet',
      content: 'Are you sure you want to delete this diet?',
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || !mounted) return;

    _controller.removeDietLocally(index);

    final snackBarController = SnackbarHelper.showUndoSnackbar(
      context: context,
      message: '${diet.name} deleted',
      undoLabel: l10n.undo,
    );

    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      _controller.restoreDietLocally(index, diet);
    } else if (diet.idDiet != null) {
      await _controller.deleteDietPermanently(diet.idDiet!);
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

  Widget _buildBodyContent(
    ThemeData theme,
    AppLocalizations l10n,
    Color dietColor,
  ) {
    if (_controller.isLoading && _controller.pendingDiet == null) {
      return Center(child: CircularProgressIndicator(color: dietColor));
    }

    if (_controller.error != null) {
      return Center(child: Text('Error: ${_controller.error}'));
    }

    if (_controller.diets.isEmpty && _controller.pendingDiet == null) {
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

    final int itemCount =
        _controller.diets.length + (_controller.pendingDiet != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_controller.pendingDiet != null && index == 0) {
          return _buildDietCard(
            _controller.pendingDiet!,
            -1,
            theme,
            l10n,
            isPending: true,
          );
        }

        final targetIndex = _controller.pendingDiet != null ? index - 1 : index;
        return _buildDietCard(
          _controller.diets[targetIndex],
          targetIndex,
          theme,
          l10n,
          isPending: false,
        );
      },
    );
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _buildBodyContent(theme, l10n, dietColor);
        },
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final isPending = _controller.pendingDiet != null;

          return PrimaryGradientButton(
            primaryColor: dietColor,
            isDisabled: isPending,
            onTap: () async {
              final Diet? preliminaryDiet = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateDietScreen(profile: widget.profile),
                ),
              );

              if (preliminaryDiet != null) {
                _handleDietCreation(preliminaryDiet);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: isDarkMode ? dietColor : Colors.white),
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
          );
        },
      ),
    );
  }
}
