import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../domain/models/weight_entry.dart';
import '../../data/weight_repository.dart';
import '../../../profile/data/profile_repository.dart';

class WeightEntryDialog extends StatefulWidget {
  final int idProfile;

  const WeightEntryDialog({super.key, required this.idProfile});

  @override
  State<WeightEntryDialog> createState() => _WeightEntryDialogState();
}

class _WeightEntryDialogState extends State<WeightEntryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _weightRepository = WeightRepository();
  final _profileRepository = ProfileRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles the weight entry submission with proper error handling and profile sync.
  Future<void> _submit() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    try {
      // 2. Parse value safely (handling both dots and commas)
      final String cleanText = _controller.text.replaceFirst(',', '.').trim();
      final double newWeight = double.parse(cleanText);

      // 3. Create Entry
      final entry = WeightEntry(
        idProfile: widget.idProfile,
        weight: newWeight,
        date: DateTime.now(),
      );

      // 4. Persistence (Double operation)
      // Save in history
      await _weightRepository.addWeightEntry(entry);

      // Update the main profile weight so the card in ProfileScreen updates
      final currentProfile = await _profileRepository.getProfileById(
        widget.idProfile,
      );
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(weight: newWeight);
        await _profileRepository.updateProfile(updatedProfile);
      }

      // 5. Success Navigation
      if (mounted) {
        Navigator.of(context).pop(true); // Returns true to trigger refresh
      }
    } catch (e) {
      debugPrint('Error saving weight entry: $e');
      // In case of error, the dialog stays open and you could show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.logWeightTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            suffixText: 'kg',
            hintText: '00.0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            // Helpful to ensure the user knows it was processed
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return l10n.requiredField;
            // Support both formats to avoid "silent" parse errors
            final n = double.tryParse(value.replaceFirst(',', '.'));
            if (n == null || n <= 0 || n > 600) return l10n.invalidWeight;
            return null;
          },
          // Allows submitting using the keyboard "Done" button
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel, style: TextStyle(color: theme.hintColor)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            l10n.save,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
