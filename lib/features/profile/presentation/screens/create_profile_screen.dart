import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../domain/models/profile.dart';
import '../../data/profile_repository.dart';
import 'choose_profile_screen.dart';

/// Screen responsible for both creating new profiles and editing existing ones.
/// It dynamically adapts its UI and logic based on the presence of the [profile] parameter.
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

      // Ensure legacy database values ('Masculino'/'Femenino') map correctly
      // to the robust internal system keys ('M'/'F').
      final String dbSex = widget.profile!.sex;
      if (dbSex == 'Masculino' || dbSex == 'M') {
        _selectedSex = 'M';
      } else if (dbSex == 'Femenino' || dbSex == 'F') {
        _selectedSex = 'F';
      } else {
        _selectedSex = 'M'; // Default fallback mechanism
      }
    }
  }

  @override
  void dispose() {
    // Release resources used by controllers to prevent memory leaks.
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

  /// Validates the form data and performs either an INSERT or UPDATE operation
  /// in the SQLite database depending on the current mode.
  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.selectDateWarning, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Construct the Profile entity. Retain the ID if editing an existing profile.
      final profileToSave = Profile(
        idProfile: widget.profile?.idProfile,
        name: _nameController.text,
        sex: _selectedSex, // Will securely store 'M' or 'F'
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        birthDate: _selectedDate!,
      );

      final isEditing = widget.profile != null;

      // Execute the appropriate database transaction
      if (isEditing) {
        await _repository.updateProfile(profileToSave);
      } else {
        await _repository.createProfile(profileToSave);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEditing ? l10n.profileUpdatedSuccess : l10n.profileCreatedSuccess,
                style: const TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the navigation stack and return to the Choose Profile Screen
        // to prevent returning to a stale Dashboard state.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChooseProfileScreen()),
              (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Determine dynamic UI elements based on the current mode
    final isEditing = widget.profile != null;
    final screenTitle = isEditing ? l10n.editProfileTitle : l10n.createProfileTitle;
    final buttonText = isEditing ? l10n.updateButton : l10n.createButton;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name Text Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
                validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 24),

              // Sex Selection Toggle Buttons
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

              // Body Metrics Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(labelText: l10n.weight),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(labelText: l10n.height),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Birth Date Picker Button
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

              // Form Submission Action Button
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

  /// Constructs a custom toggle button for sex selection.
  /// Visual state adapts based on whether this specific [value] matches [_selectedSex].
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
          color: isSelected ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
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