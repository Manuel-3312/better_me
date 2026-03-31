import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Profile Imports
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';

// NEW: Weight Tracking Imports
import 'package:better_me/features/profile/domain/models/weight_entry.dart';
import 'package:better_me/features/profile/data/weight_repository.dart';

// Other Screen Imports
import 'package:better_me/features/home/presentation/screens/main_screen.dart';

/// Screen responsible for both creating new profiles and editing existing ones.
/// It dynamically adapts its UI and navigation logic based on the [profile] parameter.
class CreateProfileScreen extends StatefulWidget {
  final Profile? profile;

  const CreateProfileScreen({super.key, this.profile});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProfileRepository();

  // NEW: Weight repository instance
  final _weightRepository = WeightRepository();

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedSex = 'M';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _weightController.text = widget.profile!.weight.toString();
      _heightController.text = widget.profile!.height.toString();
      _selectedDate = widget.profile!.birthDate;
      _selectedSex = widget.profile!.sex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Validates form data, saves the profile to SQLite, and persists the session.
  /// If it's a new profile, it also initializes the weight history with the starting weight.
  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
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

      final isEditing = widget.profile != null;

      var profileToSave = Profile(
        idProfile: widget.profile?.idProfile,
        name: _nameController.text.trim(),
        sex: _selectedSex,
        weight: double.parse(_weightController.text.replaceFirst(',', '.')),
        height: double.parse(_heightController.text.replaceFirst(',', '.')),
        birthDate: _selectedDate!,
      );

      // Async gap starts here
      if (isEditing) {
        await _repository.updateProfile(profileToSave);
      } else {
        final newId = await _repository.createProfile(profileToSave);
        profileToSave = profileToSave.copyWith(idProfile: newId);

        // Record the initial weight in history
        await _weightRepository.addWeightEntry(WeightEntry(
          idProfile: newId,
          weight: profileToSave.weight,
          date: DateTime.now(),
        ));
      }

      // Check if context is still valid after async operations
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? l10n.profileUpdatedSuccess
                : l10n.profileCreatedSuccess,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      if (isEditing) {
        Navigator.pop(context, true);
      } else {
        final prefs = await SharedPreferences.getInstance();

        if (profileToSave.idProfile != null) {
          await prefs.setInt('last_profile_id', profileToSave.idProfile!);
        }

        // Re-check mounted status before final navigation
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(profile: profileToSave),
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
    final screenTitle = isEditing ? l10n.editProfileTitle : l10n.createProfileTitle;
    final buttonText = isEditing ? l10n.updateButton : l10n.createButton;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.sex,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.hintColor),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: l10n.height,
                        suffixText: 'cm',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? l10n.birthDate
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSexToggleButton({
    required String value,
    required String label,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isSelected = _selectedSex == value;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.hintColor;

    return InkWell(
      onTap: () => setState(() => _selectedSex = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : theme.cardColor,
          border: Border.all(
            color: isSelected ? activeColor : theme.dividerColor.withValues(alpha: 0.1),
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