import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';

/// Screen responsible for capturing user input to configure a new dietary plan.
/// It returns the preliminary Diet object to be processed asynchronously by the parent screen.
class CreateDietScreen extends StatefulWidget {
  final Profile profile;

  const CreateDietScreen({super.key, required this.profile});

  @override
  State<CreateDietScreen> createState() => _CreateDietScreenState();
}

class _CreateDietScreenState extends State<CreateDietScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _additionalDataController = TextEditingController();

  String _selectedObjective = 'weightLoss';

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _additionalDataController.dispose();
    super.dispose();
  }

  void _submitDietConfiguration() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.idProfile == null) return;

    final preliminaryDiet = Diet(
      idProfile: widget.profile.idProfile!,
      name: _nameController.text.trim(),
      objective: _selectedObjective,
      allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
      additionalData: _additionalDataController.text.trim().isEmpty ? null : _additionalDataController.text.trim(),
    );

    Navigator.pop(context, preliminaryDiet);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const Color dietColor = Colors.orangeAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createDietTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.dietName,
                  prefixIcon: const Icon(Icons.restaurant_menu, color: dietColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: dietColor, width: 2),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.dietObjective,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.hintColor),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildObjectiveButton('weightLoss', l10n.weightLoss, Icons.trending_down, theme)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildObjectiveButton('maintenance', l10n.maintenance, Icons.trending_flat, theme)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildObjectiveButton('muscleGain', l10n.muscleGain, Icons.trending_up, theme)),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: l10n.dietAllergies,
                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                  hintText: l10n.dietAllergiesHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _additionalDataController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.dietAdditionalData,
                  prefixIcon: const Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                  hintText: l10n.dietAdditionalDataHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      theme.colorScheme.surface.withValues(alpha: 0.9),
                    ]
                        : [
                      dietColor,
                      dietColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: isDarkMode
                      ? Border.all(color: dietColor.withValues(alpha: 0.3))
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _submitDietConfiguration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          l10n.createButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? dietColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveButton(String value, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedObjective == value;
    const activeColor = Colors.orangeAccent;
    final inactiveBorder = theme.dividerColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : theme.cardColor,
          border: Border.all(
            color: isSelected ? activeColor : inactiveBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : theme.hintColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? activeColor : theme.hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}