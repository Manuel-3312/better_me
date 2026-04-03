import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/presentation/controllers/trainings_controller.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';
import 'create_training_screen.dart';
import './training_detail_screen.dart';
import 'favorite_exercises_screen.dart';

/// Primary interface for displaying and managing the user's training plans.
class TrainingsScreen extends StatefulWidget {
  final Profile profile;

  const TrainingsScreen({super.key, required this.profile});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  late final TrainingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TrainingsController();
    if (widget.profile.idProfile != null) {
      _controller.loadTrainings(widget.profile.idProfile!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTrainingCreation(Training preliminaryTraining) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

    await _controller.generateTrainingInBackground(
      preliminaryTraining: preliminaryTraining,
      profile: widget.profile,
      languageInstruction: languageInstruction,
      onSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.trainingCreatedSuccess),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      },
      onError: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorGeneratingTraining),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }

  Future<void> _confirmAndDeleteTraining(Training training, int index) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: 'Delete Training',
      content: 'Are you sure you want to delete this training plan?',
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || !mounted) return;

    _controller.removeTrainingLocally(index);

    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${training.name} deleted'),
        action: SnackBarAction(
          label: l10n.undo.toUpperCase(),
          textColor: Colors.blueAccent,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      _controller.restoreTrainingLocally(index, training);
    } else if (training.idTraining != null) {
      await _controller.deleteTrainingPermanently(training.idTraining!);
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

  Widget _buildTrainingCard(
    Training training,
    int index,
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
                    onPressed: () => _confirmAndDeleteTraining(training, index),
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
                    builder: (context) => TrainingDetailScreen(
                      training: training,
                      profile: widget.profile,
                    ),
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
    Color trainingColor,
  ) {
    if (_controller.isLoading && _controller.pendingTraining == null) {
      return Center(child: CircularProgressIndicator(color: trainingColor));
    }

    if (_controller.error != null) {
      return Center(child: Text('Error: ${_controller.error}'));
    }

    if (_controller.trainings.isEmpty && _controller.pendingTraining == null) {
      return Center(
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
              l10n.noTrainingsMessage,
              style: TextStyle(fontSize: 16, color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    final int itemCount =
        _controller.trainings.length +
        (_controller.pendingTraining != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_controller.pendingTraining != null && index == 0) {
          return _buildTrainingCard(
            _controller.pendingTraining!,
            -1,
            theme,
            l10n,
            trainingColor,
            isPending: true,
          );
        }

        final targetIndex = _controller.pendingTraining != null
            ? index - 1
            : index;
        return _buildTrainingCard(
          _controller.trainings[targetIndex],
          targetIndex,
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _buildBodyContent(theme, l10n, trainingColor);
        },
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final isPending = _controller.pendingTraining != null;

          return PrimaryGradientButton(
            primaryColor: trainingColor,
            isDisabled: isPending,
            onTap: () async {
              final Training? preliminaryTraining = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateTrainingScreen(profile: widget.profile),
                ),
              );

              if (preliminaryTraining != null) {
                _handleTrainingCreation(preliminaryTraining);
              }
            },
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
          );
        },
      ),
    );
  }
}
