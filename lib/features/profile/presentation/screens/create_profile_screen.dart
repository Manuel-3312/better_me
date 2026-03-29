import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../domain/models/profile.dart';
import '../../data/profile_repository.dart';
import 'choose_profile_screen.dart';

/// Screen responsible for rendering the profile creation form.
/// It captures user physical data and persists it into the local database.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  /// Global key used to validate the state of the form fields.
  final _formKey = GlobalKey<FormState>();

  /// Repository instance handling SQLite database operations for the Profile entity.
  final ProfileRepository _repository = ProfileRepository();

  /// Controllers to manage and retrieve data from the text input fields.
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  /// Internal state variable for the selected sex.
  /// Stored as 'M' (Male) or 'F' (Female) in the database to remain language-agnostic.
  String _selectedSex = 'M';

  /// Internal state variable for the user's selected birth date.
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Release resources used by controllers when the widget is unmounted.
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Triggers a native DatePicker dialog and updates the component's state
  /// with the user's selected date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Validates the form data, constructs a Profile model, and saves it
  /// to the persistent storage. On success, redirects to the selection screen.
  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate textual inputs and ensure a date has been selected.
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

      // Construct the Profile entity with the validated data.
      final newProfile = Profile(
        name: _nameController.text,
        sex: _selectedSex,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        birthDate: _selectedDate!,
      );

      // Persist data using the repository pattern.
      await _repository.createProfile(newProfile);

      // Verify the widget is still mounted before interacting with the UI context.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileCreatedSuccess, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );

        // Perform a push replacement to prevent the user from navigating back to the form.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChooseProfileScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings dynamically based on the current system locale.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createProfileTitle,
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
              // Full Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
                validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),

              // Biological Sex Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSex,
                decoration: InputDecoration(labelText: l10n.sex),
                items: [
                  DropdownMenuItem(value: 'M', child: Text(l10n.male)),
                  DropdownMenuItem(value: 'F', child: Text(l10n.female)),
                ],
                onChanged: (newValue) => setState(() => _selectedSex = newValue!),
              ),
              const SizedBox(height: 16),

              // Body Metrics Row (Weight and Height)
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

              // Date of Birth Selector
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? l10n.birthDate
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
              const SizedBox(height: 40),

              // Form Submission Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
}