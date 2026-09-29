import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/presentation/controllers/create_profile_controller.dart';
import 'package:better_me/features/home/presentation/screens/main_screen.dart';

/// Screen interface for capturing and submitting user profile data.
class CreateProfileScreen extends StatefulWidget {
  final Profile? profile;

  const CreateProfileScreen({super.key, this.profile});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  late final CreateProfileController _controller;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CreateProfileController();
    _controller.initialize(widget.profile);

    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _weightController.text = widget.profile!.weight.toString();
      _heightController.text = widget.profile!.height.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.setDate(picked);
    }
  }

  Future<void> _handleSubmission() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_controller.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.selectDateWarning,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double weight = double.parse(
      _weightController.text.replaceFirst(',', '.'),
    );
    final double height = double.parse(
      _heightController.text.replaceFirst(',', '.'),
    );

    final savedProfile = await _controller.saveProfile(
      existingProfile: widget.profile,
      name: _nameController.text.trim(),
      weight: weight,
      height: height,
    );

    if (!mounted) return;

    if (savedProfile != null) {
      final isEditing = widget.profile != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? l10n.profileUpdatedSuccess : l10n.profileCreatedSuccess,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      if (isEditing) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(profile: savedProfile),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.profile != null;
    final screenTitle = isEditing
        ? l10n.editProfileTitle
        : l10n.createProfileTitle;
    final buttonText = isEditing ? l10n.updateButton : l10n.createButton;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.fullName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.sex,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSexToggleButton(
                          value: 'M',
                          label: l10n.male,
                          icon: Icons.male,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSexToggleButton(
                          value: 'F',
                          label: l10n.female,
                          icon: Icons.female,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: l10n.weight,
                            suffixText: 'kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.requiredField
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: l10n.height,
                            suffixText: 'cm',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.requiredField
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _controller.selectedDate == null
                          ? l10n.birthDate
                          : '${_controller.selectedDate!.day}/${_controller.selectedDate!.month}/${_controller.selectedDate!.year}',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _controller.isSaving ? null : _handleSubmission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSexToggleButton({
    required String value,
    required String label,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = _controller.selectedSex == value;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.hintColor;

    return InkWell(
      onTap: () => _controller.setSex(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? activeColor
                : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
