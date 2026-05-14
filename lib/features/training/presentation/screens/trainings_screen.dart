import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';
import 'package:better_me/core/utils/search_helper.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/utils/training_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'create_training_screen.dart';
import './training_detail_screen.dart';
import 'package:better_me/features/training/data/favorite_exercises_repository.dart';
import 'package:better_me/features/training/domain/models/favorite_exercise.dart';
import 'favorite_exercises_screen.dart';
import 'package:better_me/main.dart';

class TrainingsScreen extends StatefulWidget {
  final Profile profile;

  const TrainingsScreen({super.key, required this.profile});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> with RouteAware, AutomaticKeepAliveClientMixin{
  final TrainingRepository _repository = TrainingRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();
  late final GeminiService _geminiService;
  @override
  bool get wantKeepAlive => true;

  List<Training> _trainings = [];
  bool _isLoadingTrainings = true;
  String? _error;

  Training? _pendingTraining;

  String _searchQuery = '';
  String _sortOption = 'recent';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _loadTrainings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    if (widget.profile.idProfile == null) return;

    setState(() {
      _isLoadingTrainings = true;
      _error = null;
    });

    try {
      final trainings = await _repository.getTrainingsByProfile(
        widget.profile.idProfile!,
      );
      if (mounted) {
        setState(() {
          _trainings = trainings;
          _isLoadingTrainings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingTrainings = false;
        });
      }
    }
  }

  List<Training> _getFilteredAndSortedTrainings(AppLocalizations l10n) {
    return SearchHelper.filterAndSort<Training>(
      items: _trainings,
      searchQuery: _searchQuery,
      sortOption: _sortOption,
      getName: (training) => training.name,
      getObjective: (training) =>
          _getLocalizedObjective(training.objective, l10n),
      getId: (training) => training.idTraining ?? 0,
    );
  }

  Future<void> _generateTrainingInBackground(
    Training preliminaryTraining,
  ) async {
    setState(() => _pendingTraining = preliminaryTraining);

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

    try {
      final availableExercises = await _localDb.getAllExercises();
      if (availableExercises.isEmpty) {
        throw Exception('Exercise database is empty.');
      }

      final favRepo = FavoriteExercisesRepository();
      final includeFavs = await favRepo.getIncludeFavoritesPreference();

      List<FavoriteExercise> targetFavorites = [];
      if (includeFavs) {
        targetFavorites = await favRepo.getFavorites(
          preliminaryTraining.idProfile,
          objective: preliminaryTraining.objective,
        );
      }

      final prompt = TrainingPromptBuilder.buildTrainingPrompt(
        widget.profile,
        preliminaryTraining,
        languageInstruction,
        availableExercises,
        favoriteExercises: targetFavorites,
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
      final aiPlan = AiTrainingPlan.fromJson(jsonMap);

      final finalTraining = Training(
        idProfile: preliminaryTraining.idProfile,
        name: preliminaryTraining.name,
        objective: preliminaryTraining.objective,
        maxDays: preliminaryTraining.maxDays,
        maxTime: preliminaryTraining.maxTime,
        generatedContent: cleanJsonString,
      );

      await _repository.saveFullAiTrainingPlan(finalTraining, aiPlan);

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.trainingCreatedSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating training: $e');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneratingTraining),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pendingTraining = null);
        _loadTrainings();
      }
    }
  }

  Future<void> _confirmAndDeleteTraining(Training training) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: l10n.deleteTrainingTitle,
      content: l10n.deleteTrainingContent,
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || !mounted) return;

    final originalIndex = _trainings.indexOf(training);
    if (originalIndex == -1) return;

    setState(() {
      _trainings.removeAt(originalIndex);
    });

    final snackBarController = SnackbarHelper.showUndoSnackbar(
      context: context,
      message: l10n.trainingDeleted(training.name),
      undoLabel: l10n.undo,
    );

    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      if (mounted) {
        setState(() {
          _trainings.insert(originalIndex, training);
        });
      }
    } else {
      if (training.idTraining != null) {
        try {
          await _repository.deleteTraining(training.idTraining!);
        } catch (e) {
          debugPrint('Error deleting training from database: $e');
        }
      }
    }
  }

  Widget _buildObjectiveIcon(
    String objective,
    ThemeData theme,
    Color iconColor,
  ) {
    String assetPath;
    switch (objective) {
      case 'strength':
        assetPath = 'assets/icons/strength.svg';
        break;
      case 'endurance':
        assetPath = 'assets/icons/endurance.svg';
        break;
      default:
        assetPath = 'assets/icons/hypertrophy.svg';
        break;
    }

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
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
                hintText: l10n.searchRoutine,
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

  Widget _buildTrainingCard(
    Training training,
    ThemeData theme,
    AppLocalizations l10n,
    Color trainingColor, {
    bool isPending = false,
  }) {
    final localizedObjective = _getLocalizedObjective(training.objective, l10n);

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
            color: trainingColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildObjectiveIcon(training.objective, theme, trainingColor),
        ),
        title: Text(
          training.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            isPending
                ? '$localizedObjective • ${l10n.generatingAiPlan}'
                : '$localizedObjective • ${l10n.daysPerWeek(training.maxDays)}',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        trailing: isPending
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: trainingColor,
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
                    onPressed: () => _confirmAndDeleteTraining(training),
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
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TrainingDetailScreen(training: training),
                  ),
                );
                // NOTA: Dejé el _loadTrainings() original aquí como pediste para no borrar código innecesariamente,
                // aunque didPopNext ya se encargará de refrescar la pantalla también.
                _loadTrainings();
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
    Color trainingColor,
  ) {
    if (_isLoadingTrainings && _pendingTraining == null) {
      return Center(child: CircularProgressIndicator(color: trainingColor));
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final displayTrainings = _getFilteredAndSortedTrainings(l10n);

    if (displayTrainings.isEmpty && _pendingTraining == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.fitness_center : Icons.search_off,
              size: 80,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? l10n.noTrainingsMessage
                  : 'No hay rutinas que coincidan',
              style: TextStyle(fontSize: 16, color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    final int itemCount =
        displayTrainings.length + (_pendingTraining != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_pendingTraining != null && index == 0) {
          return _buildTrainingCard(
            _pendingTraining!,
            theme,
            l10n,
            trainingColor,
            isPending: true,
          );
        }

        final targetIndex = _pendingTraining != null ? index - 1 : index;
        return _buildTrainingCard(
          displayTrainings[targetIndex],
          theme,
          l10n,
          trainingColor,
          isPending: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color trainingColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.trainingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            color: trainingColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoriteExercisesScreen(profile: widget.profile),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, l10n),
          Expanded(child: _buildBodyContent(theme, l10n, trainingColor)),
        ],
      ),
      floatingActionButton: Opacity(
        opacity: _pendingTraining != null ? 0.5 : 1.0,
        child: AbsorbPointer(
          absorbing: _pendingTraining != null,
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
                    : [trainingColor, trainingColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: isDarkMode
                  ? Border.all(color: trainingColor.withValues(alpha: 0.3))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: trainingColor.withValues(alpha: 0.2),
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
                  final Training? preliminaryTraining = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateTrainingScreen(profile: widget.profile),
                    ),
                  );

                  if (preliminaryTraining != null) {
                    _generateTrainingInBackground(preliminaryTraining);
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
                        color: isDarkMode ? trainingColor : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.createTraining,
                        style: TextStyle(
                          color: isDarkMode ? trainingColor : Colors.white,
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
}
