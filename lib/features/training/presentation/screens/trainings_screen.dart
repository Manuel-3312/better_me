import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Added SVG import
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/training_repository.dart';
import '../../domain/models/training.dart';
import 'create_training_screen.dart';

/// Screen responsible for displaying all training plans associated with a specific profile.
/// It visually differentiates training routines by displaying their specific objective SVG icon.
class TrainingsScreen extends StatefulWidget {
  /// The active profile used to filter the training plans.
  final Profile profile;

  const TrainingsScreen({super.key, required this.profile});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  /// Repository instance handling Training database operations.
  final TrainingRepository _repository = TrainingRepository();

  /// Future that holds the list of training plans for the active profile.
  late Future<List<Training>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  /// Initiates the database query to fetch training plans associated with the current profile ID.
  void _loadTrainings() {
    setState(() {
      _trainingsFuture = _repository.getTrainingsByProfile(widget.profile.idProfile!);
    });
  }

  /// Helper method to return the correct SVG icon based on the training objective.
  /// Falls back to the hypertrophy icon if the objective is unrecognized.
  Widget _buildObjectiveIcon(String objective) {
    String assetPath;

    switch (objective) {
      case 'strength':
        assetPath = 'assets/icons/strength.svg';
        break;
      case 'endurance':
        assetPath = 'assets/icons/endurance.svg';
        break;
      case 'hypertrophy':
      default:
        assetPath = 'assets/icons/hypertrophy.svg';
        break;
    }

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
    );
  }

  /// Helper method to translate the database objective key into localized text.
  String _getLocalizedObjective(String objective, AppLocalizations l10n) {
    switch (objective) {
      case 'strength':
        return l10n.strength;
      case 'endurance':
        return l10n.endurance;
      case 'hypertrophy':
      default:
        return l10n.hypertrophy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n.trainingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Training>>(
        future: _trainingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTrainingsMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final trainings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trainings.length,
            itemBuilder: (context, index) {
              final training = trainings[index];

              // Get localized text for the objective
              final localizedObjective = _getLocalizedObjective(training.objective, l10n);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    // Use the helper method to render the SVG dynamically
                    child: _buildObjectiveIcon(training.objective),
                  ),
                  title: Text(training.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$localizedObjective • ${training.maxDays} days/week'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to training details / days (Next Step)
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
        label: Text(l10n.createTraining, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
    );
  }
}