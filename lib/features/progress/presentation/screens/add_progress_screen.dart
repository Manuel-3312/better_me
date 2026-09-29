import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/progress/presentation/controllers/add_progress_controller.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';

/// Screen responsible for capturing new progress data including weight and photos.
class AddProgressScreen extends StatefulWidget {
  final Profile profile;

  const AddProgressScreen({super.key, required this.profile});

  @override
  State<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends State<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  late final AddProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddProgressController();
    _weightController.text = widget.profile.weight.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.setDate(picked);
    }
  }

  Future<void> _saveProgress() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() ||
        widget.profile.idProfile == null) {
      return;
    }

    final success = await _controller.saveProgress(
      profileId: widget.profile.idProfile!,
      weight: double.parse(_weightController.text),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.saveProgressError),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.logProgress,
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
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dateLabel,
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(_controller.selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.weightKgLabel,
                      prefixIcon: Icon(Icons.scale, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      if (double.tryParse(value) == null) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.progressPhotos,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _controller.pickImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(l10n.addButton),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_controller.selectedImages.isNotEmpty)
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 12.0,
                                  top: 8.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _controller.selectedImages[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  if (_controller.selectedImages.isEmpty)
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.noPhotosAdded,
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),

                  PrimaryGradientButton(
                    primaryColor: primaryColor,
                    isLoading: _controller.isSaving,
                    onTap: _saveProgress,
                    child: Text(
                      l10n.saveProgress,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? primaryColor : Colors.white,
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
}
