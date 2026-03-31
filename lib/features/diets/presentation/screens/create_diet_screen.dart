import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/diets/data/diet_repository.dart';
import 'package:better_me/features/diets/domain/models/diet.dart';
import 'package:better_me/features/diets/domain/models/ai_diet_plan.dart'; // New DTO import
import 'package:better_me/features/diets/domain/utils/diet_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';

/// Screen responsible for capturing user input to generate a new dietary plan via AI.
/// Features a night-mode optimized UI with high-precision colors and a generation overlay.
class CreateDietScreen extends StatefulWidget {
  final Profile profile;

  const CreateDietScreen({super.key, required this.profile});

  @override
  State<CreateDietScreen> createState() => _CreateDietScreenState();
}

class _CreateDietScreenState extends State<CreateDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DietRepository();
  late final GeminiService _geminiService;

  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _additionalDataController = TextEditingController();

  String _selectedObjective = 'weightLoss';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _additionalDataController.dispose();
    super.dispose();
  }

  /// Handles form validation, AI communication, and JSON verification before persistence.
  Future<void> _saveDiet() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.idProfile == null) return;

    setState(() => _isGenerating = true);

    try {
      final preliminaryDiet = Diet(
        idProfile: widget.profile.idProfile!,
        name: _nameController.text.trim(),
        objective: _selectedObjective,
        allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
        additionalData: _additionalDataController.text.trim().isEmpty ? null : _additionalDataController.text.trim(),
      );

      final locale = Localizations.localeOf(context).languageCode;
      final languageInstruction = locale == 'es' ? 'Spanish' : 'English';

      final prompt = DietPromptBuilder.buildDietPrompt(
        widget.profile,
        preliminaryDiet,
        language: languageInstruction,
      );

      final responseText = await _geminiService.generateContent(prompt);
      if (responseText == null || responseText.isEmpty) throw Exception('Empty AI response');

      final cleanJsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // JSON Validation: Ensure the response matches our AiDietPlan structure
      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      AiDietPlan.fromJson(jsonMap);

      final finalDiet = Diet(
        idProfile: preliminaryDiet.idProfile,
        name: preliminaryDiet.name,
        objective: preliminaryDiet.objective,
        allergies: preliminaryDiet.allergies,
        additionalData: preliminaryDiet.additionalData,
        generatedContent: cleanJsonString,
      );

      await _repository.createDiet(finalDiet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dietCreatedSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error generating diet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.errorGeneratingDiet),
              backgroundColor: Colors.redAccent
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createDietTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isGenerating,
                    decoration: InputDecoration(
                      labelText: l10n.dietName,
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    enabled: !_isGenerating,
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
                    enabled: !_isGenerating,
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
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _saveDiet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.createButton,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isGenerating)
            Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.orangeAccent),
                    const SizedBox(height: 20),
                    Text(
                      l10n.cookingAiPlan,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildObjectiveButton(String value, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedObjective == value;
    const activeColor = Colors.orangeAccent;
    final inactiveBorder = theme.dividerColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: _isGenerating ? null : () => setState(() => _selectedObjective = value),
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