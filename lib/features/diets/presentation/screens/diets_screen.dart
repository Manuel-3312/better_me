import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';
import 'package:better_me/core/utils/search_helper.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/presentation/controllers/diets_controller.dart';
import 'package:better_me/features/diets/presentation/screens/diet_detail_screen.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';
import 'coockbook_screen.dart';
import 'create_diet_screen.dart';
import 'package:better_me/main.dart';

/// Primary interface for displaying and managing the user's dietary plans.
class DietsScreen extends StatefulWidget {
  final Profile profile;

  const DietsScreen({super.key, required this.profile});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> with RouteAware, AutomaticKeepAliveClientMixin {
  late final DietsController _controller;

  String _searchQuery = '';
  String _sortOption = 'recent';
  final TextEditingController _searchController = TextEditingController();
  @override
  bool get wantKeepAlive => true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (widget.profile.idProfile != null) {
      _controller.loadDiets(widget.profile.idProfile!);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = DietsController();
    if (widget.profile.idProfile != null) {
      _controller.loadDiets(widget.profile.idProfile!);
    }
  }

  List<Diet> _getFilteredAndSortedDiets(AppLocalizations l10n) {
    return SearchHelper.filterAndSort<Diet>(
      items: _controller.diets,
      searchQuery: _searchQuery,
      sortOption: _sortOption,
      getName: (diet) => diet.name,
      getObjective: (diet) => _getLocalizedObjective(diet.objective, l10n),
      getId: (diet) => diet.idDiet ?? 0,
    );
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

  Future<void> _confirmAndDeleteDiet(Diet diet) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: l10n.deleteDietTitle,
      content: l10n.deleteDietContent,
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || !mounted) return;

    final originalIndex = _controller.diets.indexOf(diet);
    if (originalIndex == -1) return;

    _controller.removeDietLocally(originalIndex);

    final snackBarController = SnackbarHelper.showUndoSnackbar(
      context: context,
      message: l10n.dietDeleted(diet.name),
      undoLabel: l10n.undo,
    );
    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      _controller.restoreDietLocally(originalIndex, diet);
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

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: l10n.searchDiet,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: isEs ? 'Ordenar' : 'Sort',
            initialValue: _sortOption,
            onSelected: (String newValue) {
              setState(() => _sortOption = newValue);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'recent',
                child: Text(isEs ? 'Más recientes' : 'Most recent'),
              ),
              PopupMenuItem<String>(
                value: 'az',
                child: Text(isEs ? 'Nombre (A-Z)' : 'Name (A-Z)'),
              ),
              PopupMenuItem<String>(
                value: 'za',
                child: Text(isEs ? 'Nombre (Z-A)' : 'Name (Z-A)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietCard(
      Diet diet,
      ThemeData theme,
      AppLocalizations l10n, {
        bool isPending = false,
      }) {
    final Color dietColor = Colors.orangeAccent;
    final String localizedObjective = _getLocalizedObjective(diet.objective, l10n);
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
        contentPadding: const EdgeInsets.only(left: 12, right: 8, top: 12, bottom: 12),
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
            isPending ? '$localizedObjective • ${l10n.cookingAiPlan}' : localizedObjective,
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
              onPressed: () => _confirmAndDeleteDiet(diet),
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
              builder: (context) => DietDetailScreen(diet: diet, profile: widget.profile),
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

  Widget _buildBodyContent(ThemeData theme, AppLocalizations l10n, Color dietColor) {
    if (_controller.isLoading && _controller.pendingDiet == null) {
      return Center(child: CircularProgressIndicator(color: dietColor));
    }

    if (_controller.error != null) {
      return Center(child: Text('Error: ${_controller.error}'));
    }

    final displayDiets = _getFilteredAndSortedDiets(l10n);

    if (displayDiets.isEmpty && _controller.pendingDiet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.restaurant_menu : Icons.search_off,
              size: 80,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? l10n.noDietsMessage : 'No hay dietas que coincidan con la búsqueda',
              style: TextStyle(fontSize: 16, color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final int itemCount = displayDiets.length + (_controller.pendingDiet != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_controller.pendingDiet != null && index == 0) {
          return _buildDietCard(_controller.pendingDiet!, theme, l10n, isPending: true);
        }

        final targetIndex = _controller.pendingDiet != null ? index - 1 : index;
        return _buildDietCard(displayDiets[targetIndex], theme, l10n, isPending: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          return Column(
            children: [
              _buildSearchBar(theme, l10n),
              Expanded(
                child: _buildBodyContent(theme, l10n, dietColor),
              ),
            ],
          );
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
                  builder: (context) => CreateDietScreen(profile: widget.profile),
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