import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

// Absolute imports
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/data/training_repository.dart';
import 'package:better_me/features/training/domain/models/training.dart';
import 'package:better_me/features/training/domain/models/ai_training_plan.dart';
import 'package:better_me/features/training/domain/utils/training_prompt_builder.dart';
import 'package:better_me/core/network/gemini_service.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/wger_exercise.dart';
import 'package:better_me/features/training/domain/models/test_wger_screen.dart';

class CreateTrainingScreen extends StatefulWidget {
  final Profile profile;

  const CreateTrainingScreen({super.key, required this.profile});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TrainingRepository();
  final _localDb = ExerciseLocalDatabase();
  late final GeminiService _geminiService;
  final _nameController = TextEditingController();

  String _selectedObjective = 'hypertrophy';
  double _maxDays = 3.0;
  double _maxTime = 60.0;
  bool _isGenerating = false;
  bool _isDbEmpty = false; // Flag to check if we need to sync

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _checkDatabase();
  }

  /// Checks if the local database has exercises to avoid errors during generation.
  Future<void> _checkDatabase() async {
    final hasData = await _localDb.hasData();
    setState(() => _isDbEmpty = !hasData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _getIntensityColor(double value, double min, double max, bool isDarkMode) {
    final double percentage = (value - min) / (max - min);
    return Color.lerp(
      isDarkMode ? Colors.cyanAccent : Colors.lightBlue.shade300,
      isDarkMode ? Colors.orangeAccent : Colors.red.shade700,
      percentage,
    ) ?? Colors.blue;
  }

  Future<void> _saveTraining() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.idProfile == null) return;

    setState(() => _isGenerating = true);

    try {
      final List<WgerExercise> availableExercises = await _localDb.getAllExercises();

      if (availableExercises.isEmpty) {
        throw Exception('Exercise database is empty. Please sync first.');
      }

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
        availableExercises,
      );

      final responseText = await _geminiService.generateContent(prompt);
      if (responseText == null || responseText.isEmpty) throw Exception('Empty AI response');

      final cleanJsonString = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> jsonMap = jsonDecode(cleanJsonString);
      final aiPlan = AiTrainingPlan.fromJson(jsonMap);

      final finalTrainingHeader = Training(
        idProfile: preliminaryTraining.idProfile,
        name: preliminaryTraining.name,
        objective: preliminaryTraining.objective,
        maxDays: preliminaryTraining.maxDays,
        maxTime: preliminaryTraining.maxTime,
        generatedContent: cleanJsonString,
      );

      await _repository.saveFullAiTrainingPlan(finalTrainingHeader, aiPlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.trainingCreatedSuccess), backgroundColor: Colors.green.shade700),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneratingTraining), backgroundColor: Colors.redAccent),
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
        title: Text(l10n.createTrainingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Icono en la esquina superior derecha
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Database',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestWgerScreen()),
              );
              _checkDatabase(); // Refresh status when coming back
            },
          ),
        ],
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
                  // --- BOTÓN DE ALERTA SI LA DB ESTÁ VACÍA ---
                  if (_isDbEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'Database is empty!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text('You need to sync exercises before creating a plan.', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TestWgerScreen()),
                              );
                              _checkDatabase();
                            },
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Sync Now'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  TextFormField(
                    controller: _nameController,
                    enabled: !_isGenerating,
                    decoration: InputDecoration(
                      labelText: l10n.trainingName,
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 32),
                  // ... resto de los Sliders y botones que ya tienes ...
                  Text(l10n.trainingObjective, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.hintColor)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildObjectiveButton('hypertrophy', l10n.hypertrophy, 'assets/icons/hypertrophy.svg', theme)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildObjectiveButton('strength', l10n.strength, 'assets/icons/strength.svg', theme)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildObjectiveButton('endurance', l10n.endurance, 'assets/icons/endurance.svg', theme)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildSliderLabel(l10n.maxDaysLabel(_maxDays.toInt()), daysColor),
                  Slider(
                    value: _maxDays,
                    min: 1, max: 7, divisions: 6,
                    activeColor: daysColor,
                    inactiveColor: daysColor.withOpacity(0.2),
                    onChanged: _isGenerating ? null : (v) => setState(() => _maxDays = v),
                  ),
                  const SizedBox(height: 32),
                  _buildSliderLabel(l10n.maxTimeLabel(_maxTime.toInt()), timeColor),
                  Slider(
                    value: _maxTime,
                    min: 15, max: 180, divisions: 11,
                    activeColor: timeColor,
                    inactiveColor: timeColor.withOpacity(0.2),
                    onChanged: _isGenerating ? null : (v) => setState(() => _maxTime = v),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isGenerating || _isDbEmpty ? null : _saveTraining,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.createButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          if (_isGenerating)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.generatingAiPlan, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildObjectiveButton(String value, String label, String assetPath, ThemeData theme) {
    final isSelected = _selectedObjective == value;
    final isDarkMode = theme.brightness == Brightness.dark;
    final activeColor = isDarkMode ? theme.colorScheme.primary : Colors.blue.shade700;

    return InkWell(
      onTap: _isGenerating ? null : () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : theme.cardColor,
          border: Border.all(color: isSelected ? activeColor : theme.dividerColor.withOpacity(0.1), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              assetPath,
              height: 32, width: 32,
              colorFilter: ColorFilter.mode(isSelected ? activeColor : theme.hintColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(
              color: isSelected ? activeColor : theme.hintColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            )),
          ],
        ),
      ),
    );
  }
}