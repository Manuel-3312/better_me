import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/training_repository.dart';
import '../../domain/models/training.dart';

/// Screen responsible for capturing user input to generate a new training plan.
/// It utilizes interactive sliders for numerical inputs and custom SVG assets
/// for objective selection. Includes dynamic color intensity feedback for both
/// frequency (days) and volume (time).
class CreateTrainingScreen extends StatefulWidget {
  /// The active user profile to which this training routine will be assigned.
  final Profile profile;

  const CreateTrainingScreen({super.key, required this.profile});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  /// Global key used to validate the state of the text form fields.
  final _formKey = GlobalKey<FormState>();

  /// Repository instance handling SQLite database operations for Trainings.
  final TrainingRepository _repository = TrainingRepository();

  /// Controller to manage the training routine name input.
  final _nameController = TextEditingController();

  /// Internal state tracking the selected training objective.
  /// Defaults to 'hypertrophy'.
  String _selectedObjective = 'hypertrophy';

  /// Internal state for the maximum number of days per week (1 to 7).
  double _maxDays = 3.0;

  /// Internal state for the maximum time per session in minutes (15 to 180).
  double _maxTime = 60.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Calculates a dynamic color based on the selected training duration (time).
  /// Transitions from a light, calm blue (light workout) to an intense red (heavy workout).
  Color _getTimeIntensityColor(double currentMinutes) {
    const double minTime = 15.0;
    const double maxTime = 180.0;

    // Calculate the percentage of intensity (0.0 to 1.0)
    final double percentage = (currentMinutes - minTime) / (maxTime - minTime);

    return Color.lerp(Colors.lightBlue.shade300, Colors.red.shade700, percentage) ?? Colors.blue;
  }

  /// Calculates a dynamic color based on the selected training frequency (days).
  /// Transitions from a light blue (1 day) to an intense red (7 days).
  Color _getDaysIntensityColor(double currentDays) {
    const double minDays = 1.0;
    const double maxDays = 7.0;

    // Calculate the percentage of intensity (0.0 to 1.0)
    final double percentage = (currentDays - minDays) / (maxDays - minDays);

    return Color.lerp(Colors.lightBlue.shade300, Colors.red.shade700, percentage) ?? Colors.blue;
  }

  /// Validates the form and persists the new Training entity to the local database.
  Future<void> _saveTraining() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (widget.profile.idProfile == null) return;

      final newTraining = Training(
        idProfile: widget.profile.idProfile!,
        name: _nameController.text.trim(),
        objective: _selectedObjective,
        maxDays: _maxDays.toInt(),
        maxTime: _maxTime,
      );

      await _repository.createTraining(newTraining);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.trainingCreatedSuccess, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Return to the Trainings list, passing true to trigger a UI refresh
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get the dynamic colors for the current slider values
    final timeIntensityColor = _getTimeIntensityColor(_maxTime);
    final daysIntensityColor = _getDaysIntensityColor(_maxDays);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTrainingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Training Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.trainingName,
                  prefixIcon: const Icon(Icons.fitness_center),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 32),

              // Custom Segmented Control for Training Objective with SVGs
              Text(
                l10n.trainingObjective,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'hypertrophy',
                      label: l10n.hypertrophy,
                      assetPath: 'assets/icons/hypertrophy.svg',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'strength',
                      label: l10n.strength,
                      assetPath: 'assets/icons/strength.svg',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'endurance',
                      label: l10n.endurance,
                      assetPath: 'assets/icons/endurance.svg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Max Days Slider (1 to 7) with dynamic coloring
              Text(
                l10n.maxDaysLabel(_maxDays.toInt()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: daysIntensityColor,
                ),
              ),
              Slider(
                value: _maxDays,
                min: 1,
                max: 7,
                divisions: 6,
                activeColor: daysIntensityColor,
                thumbColor: daysIntensityColor,
                label: _maxDays.toInt().toString(),
                onChanged: (value) {
                  setState(() => _maxDays = value);
                },
              ),
              const SizedBox(height: 24),

              // Max Time Slider (15 to 180 minutes) with dynamic coloring
              Text(
                l10n.maxTimeLabel(_maxTime.toInt()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: timeIntensityColor,
                ),
              ),
              Slider(
                value: _maxTime,
                min: 15,
                max: 180,
                divisions: 11, // 15 min increments up to 180
                activeColor: timeIntensityColor,
                thumbColor: timeIntensityColor,
                label: '${_maxTime.toInt()} min',
                onChanged: (value) {
                  setState(() => _maxTime = value);
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: _saveTraining,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.createButton,
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constructs a custom toggle button for the training objective selection using SVG assets.
  Widget _buildObjectiveButton({
    required String value,
    required String label,
    required String assetPath,
  }) {
    final isSelected = _selectedObjective == value;
    final color = isSelected ? Colors.blue : Colors.grey.shade600;

    return InkWell(
      onTap: () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              assetPath,
              height: 28,
              width: 28,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}