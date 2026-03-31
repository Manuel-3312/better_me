import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

// Absolute imports for clarity and consistency
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/home/presentation/screens/main_screen.dart';

/// Screen responsible for both creating new profiles and editing existing ones.
/// It dynamically adapts its UI and navigation logic based on the [profile] parameter.
class CreateProfileScreen extends StatefulWidget {
  /// Optional profile object. If provided, the form switches to "Edit Mode".
  final Profile? profile;

  const CreateProfileScreen({super.key, this.profile});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  /// Global key used to validate the state of the form fields.
  final _formKey = GlobalKey<FormState>();

  /// Repository instance handling SQLite database operations.
  final ProfileRepository _repository = ProfileRepository();

  /// Controllers to manage and retrieve data from the text input fields.
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  /// Internal state variable for biological sex selection ('M' or 'F').
  String _selectedSex = 'M';

  /// Internal state variable for the user's date of birth.
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // If a profile was passed, pre-fill the form fields (Edit Mode)
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

  /// Triggers a native DatePicker dialog to capture the user's birth date.
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

  /// Validates form data and performs either an INSERT or UPDATE.
  /// Navigation logic depends on whether the user is editing or creating a profile.
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
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final isEditing = widget.profile != null;

      // Prepare the profile object to be saved
      var profileToSave = Profile(
        idProfile: widget.profile?.idProfile,
        name: _nameController.text.trim(),
        sex: _selectedSex,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        birthDate: _selectedDate!,
      );

      if (isEditing) {
        await _repository.updateProfile(profileToSave);
      } else {
        // For new profiles, we capture the generated ID to enter the MainScreen immediately
        final newId = await _repository.createProfile(profileToSave);
        profileToSave = profileToSave.copyWith(idProfile: newId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? l10n.profileUpdatedSuccess
                  : l10n.profileCreatedSuccess,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        if (isEditing) {
          // Return to the Profile Tab within MainScreen and trigger a data refresh
          Navigator.pop(context, true);
        } else {
          // New profile: Enter the application directly with the fresh profile
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 24),

              Text(
                l10n.sex,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSexToggleButton(
                      value: 'M',
                      label: l10n.male,
                      icon: Icons.male,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSexToggleButton(
                      value: 'F',
                      label: l10n.female,
                      icon: Icons.female,
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
                  _selectedDate == null
                      ? l10n.birthDate
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
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

  Widget _buildSexToggleButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedSex == value;
    return InkWell(
      onTap: () => setState(() => _selectedSex = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
