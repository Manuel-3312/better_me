import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/training_repository.dart';
import '../../domain/models/training.dart';
import 'create_training_screen.dart';
import './training_detail_screen.dart';

/// Screen responsible for displaying all training plans associated with a specific profile.
/// Refactored for modern high-precision color values and dynamic theme support.
class TrainingsScreen extends StatefulWidget {
  final Profile profile;

  const TrainingsScreen({super.key, required this.profile});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  final TrainingRepository _repository = TrainingRepository();
  late Future<List<Training>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  void _loadTrainings() {
    setState(() {
      _trainingsFuture = _repository.getTrainingsByProfile(widget.profile.idProfile!);
    });
  }

  /// Renders the SVG icon with a theme-aware color filter.
  Widget _buildObjectiveIcon(String objective, ThemeData theme) {
    String assetPath;
    switch (objective) {
      case 'strength': assetPath = 'assets/icons/strength.svg'; break;
      case 'endurance': assetPath = 'assets/icons/endurance.svg'; break;
      default: assetPath = 'assets/icons/hypertrophy.svg'; break;
    }

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      // blueAccent provides better contrast in Dark Mode than standard blue
      colorFilter: const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
    );
  }

  String _getLocalizedObjective(String objective, AppLocalizations l10n) {
    switch (objective) {
      case 'strength': return l10n.strength;
      case 'endurance': return l10n.endurance;
      default: return l10n.hypertrophy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
      ),
      body: FutureBuilder<List<Training>>(
        future: _trainingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

          final trainings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: trainings.length,
            itemBuilder: (context, index) {
              final training = trainings[index];
              final localizedObjective = _getLocalizedObjective(training.objective, l10n);

              return Card(
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
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildObjectiveIcon(training.objective, theme),
                  ),
                  title: Text(
                    training.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$localizedObjective • ${training.maxDays} days/week',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  onTap: () {
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTrainingScreen(profile: widget.profile),
            ),
          );

          if (shouldRefresh == true) {
            _loadTrainings();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.createTraining,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}