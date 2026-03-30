import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/diet_repository.dart';
import '../../domain/models/diet.dart';

/// Screen responsible for capturing user input to generate a new dietary plan.
/// It features a custom segmented control for objective selection and links
/// the newly created diet to the active [profile].
class CreateDietScreen extends StatefulWidget {
  /// The active user profile to which this diet will be assigned.
  final Profile profile;

  const CreateDietScreen({super.key, required this.profile});

  @override
  State<CreateDietScreen> createState() => _CreateDietScreenState();
}

class _CreateDietScreenState extends State<CreateDietScreen> {
  /// Global key used to validate the state of the form fields.
  final _formKey = GlobalKey<FormState>();

  /// Repository instance handling SQLite database operations for Diets.
  final DietRepository _repository = DietRepository();

  /// Controllers to manage textual user input.
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _additionalDataController = TextEditingController();

  /// Internal state variable tracking the selected dietary objective.
  /// Defaults to 'weightLoss' to ensure a valid initial state.
  String _selectedObjective = 'weightLoss';

  @override
  void dispose() {
    // Prevent memory leaks by disposing controllers when the widget is destroyed.
    _nameController.dispose();
    _allergiesController.dispose();
    _additionalDataController.dispose();
    super.dispose();
  }

  /// Validates the form and persists the new Diet entity to the local database.
  Future<void> _saveDiet() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      // Ensure the profile has a valid ID before creating relational data.
      if (widget.profile.idProfile == null) return;

      final newDiet = Diet(
        idProfile: widget.profile.idProfile!,
        name: _nameController.text.trim(),
        objective: _selectedObjective,
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        additionalData: _additionalDataController.text.trim().isEmpty
            ? null
            : _additionalDataController.text.trim(),
      );

      await _repository.createDiet(newDiet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.dietCreatedSuccess,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Pop the screen to return to the Diets list, passing true to signal a refresh is needed.
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createDietTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Diet Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.dietName,
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 32),

              // Custom Segmented Control for Diet Objective
              Text(
                l10n.dietObjective,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'weightLoss',
                      label: l10n.weightLoss,
                      icon: Icons.trending_down,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'maintenance',
                      label: l10n.maintenance,
                      icon: Icons.trending_flat, // Acts as the '=' symbol
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      value: 'muscleGain',
                      label: l10n.muscleGain,
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Allergies Field (Optional)
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: l10n.dietAllergies,
                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                  hintText: l10n.dietAllergiesHint,
                ),
              ),
              const SizedBox(height: 24),

              // Additional Data Field (Optional, Multiline)
              TextFormField(
                controller: _additionalDataController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.dietAdditionalData,
                  prefixIcon: const Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                  hintText: l10n.dietAdditionalDataHint,
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: _saveDiet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.createButton,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constructs a custom toggle button for the dietary objective selection.
  /// Visual state adapts based on whether this specific [value] matches [_selectedObjective].
  Widget _buildObjectiveButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedObjective == value;

    return InkWell(
      onTap: () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12, // Slightly smaller font to fit all three options
              ),
            ),
          ],
        ),
      ),
    );
  }
}
