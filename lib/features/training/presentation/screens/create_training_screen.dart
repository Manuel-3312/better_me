import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart'; // <-- Añadido
import 'package:better_me/features/training/domain/utils/training_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';

/// Screen responsible for capturing user input to generate a new training plan via AI.
/// Features dynamic intensity color feedback and full Night Mode support.
class CreateTrainingScreen extends StatefulWidget {
  final Profile profile;

  const CreateTrainingScreen({super.key, required this.profile});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TrainingRepository();
  late final GeminiService _geminiService;
  final _nameController = TextEditingController();

  String _selectedObjective = 'hypertrophy';
  double _maxDays = 3.0;
  double _maxTime = 60.0;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Calculates intensity color using 'Accent' variants for better visibility in Dark Mode.
  Color _getIntensityColor(
      double value,
      double min,
      double max,
      bool isDarkMode,
      ) {
    final double percentage = (value - min) / (max - min);
    return Color.lerp(
      isDarkMode ? Colors.cyanAccent : Colors.lightBlue.shade300,
      isDarkMode ? Colors.orangeAccent : Colors.red.shade700,
      percentage,
    ) ??
        Colors.blue;
  }

  /// Generates the AI plan, serializes it, and saves it into the relational database.
  Future<void> _saveTraining() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.idProfile == null) return;

    setState(() => _isGenerating = true);

    try {
      final preliminaryTraining = Training(
        idProfile: widget.profile.idProfile!,
        name: _nameController.text.trim(),
        objective: _selectedObjective,
        maxDays: _maxDays.toInt(),
        maxTime: _maxTime,
      );

      final locale = Localizations.localeOf(context).languageCode;
      final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

      final prompt = TrainingPromptBuilder.buildTrainingPrompt(
        widget.profile,
        preliminaryTraining,
        languageInstruction,
      );

      final responseText = await _geminiService.generateContent(prompt);

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty AI response');
      }

      final cleanJsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      AiTrainingPlan.fromJson(jsonMap);

      final finalTraining = Training(
        idProfile: preliminaryTraining.idProfile,
        name: preliminaryTraining.name,
        objective: preliminaryTraining.objective,
        maxDays: preliminaryTraining.maxDays,
        maxTime: preliminaryTraining.maxTime,
        generatedContent: cleanJsonString,
      );

      await _repository.createTraining(finalTraining);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.trainingCreatedSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error creating AI training: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneratingTraining),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final daysColor = _getIntensityColor(_maxDays, 1, 7, isDarkMode);
    final timeColor = _getIntensityColor(_maxTime, 15, 180, isDarkMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createTrainingTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Training Name
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isGenerating,
                    decoration: InputDecoration(
                      labelText: l10n.trainingName,
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Objective Selection
                  Text(
                    l10n.trainingObjective,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildObjectiveButton(
                          'hypertrophy',
                          l10n.hypertrophy,
                          'assets/icons/hypertrophy.svg',
                          theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildObjectiveButton(
                          'strength',
                          l10n.strength,
                          'assets/icons/strength.svg',
                          theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildObjectiveButton(
                          'endurance',
                          l10n.endurance,
                          'assets/icons/endurance.svg',
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Days Slider
                  _buildSliderLabel(
                    l10n.maxDaysLabel(_maxDays.toInt()),
                    daysColor,
                  ),
                  Slider(
                    value: _maxDays,
                    min: 1,
                    max: 7,
                    divisions: 6,
                    activeColor: daysColor,
                    inactiveColor: daysColor.withValues(alpha: 0.2),
                    onChanged: _isGenerating
                        ? null
                        : (v) => setState(() => _maxDays = v),
                  ),
                  const SizedBox(height: 32),

                  // Time Slider
                  _buildSliderLabel(
                    l10n.maxTimeLabel(_maxTime.toInt()),
                    timeColor,
                  ),
                  Slider(
                    value: _maxTime,
                    min: 15,
                    max: 180,
                    divisions: 11,
                    activeColor: timeColor,
                    inactiveColor: timeColor.withValues(alpha: 0.2),
                    onChanged: _isGenerating
                        ? null
                        : (v) => setState(() => _maxTime = v),
                  ),
                  const SizedBox(height: 48),

                  // Generate Button
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _saveTraining,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.createButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isGenerating)
            Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.generatingAiPlan,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliderLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildObjectiveButton(
      String value,
      String label,
      String assetPath,
      ThemeData theme,
      ) {
    final isSelected = _selectedObjective == value;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Custom colors for Night Mode
    final activeColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blue.shade700;
    final inactiveBorder = theme.dividerColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: _isGenerating
          ? null
          : () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : theme.cardColor,
          border: Border.all(
            color: isSelected ? activeColor : inactiveBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              assetPath,
              height: 32,
              width: 32,
              colorFilter: ColorFilter.mode(
                isSelected ? activeColor : theme.hintColor,
                BlendMode.srcIn,
              ),
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