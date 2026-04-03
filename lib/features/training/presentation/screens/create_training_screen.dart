import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/training/data/exercise_local_database.dart';
import 'package:better_me/features/training/domain/models/test_wger_screen.dart';
import 'package:better_me/features/training/domain/models/training.dart';

// Importamos el nuevo componente genérico
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';

class CreateTrainingScreen extends StatefulWidget {
  final Profile profile;

  const CreateTrainingScreen({super.key, required this.profile});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _localDb = ExerciseLocalDatabase();
  final _nameController = TextEditingController();

  String _selectedObjective = 'hypertrophy';
  double _maxDays = 3.0;
  double _maxTime = 60.0;
  bool _isDbEmpty = false;

  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    final hasData = await _localDb.hasData();
    setState(() => _isDbEmpty = !hasData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _getIntensityColor(
    double value,
    double min,
    double max,
    bool isDarkMode,
    Color baseColor,
  ) {
    final double percentage = (value - min) / (max - min);
    return Color.lerp(
          baseColor,
          isDarkMode ? Colors.orangeAccent : Colors.red.shade700,
          percentage,
        ) ??
        baseColor;
  }

  void _submitTrainingConfiguration() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.idProfile == null) return;

    final preliminaryTraining = Training(
      idProfile: widget.profile.idProfile!,
      name: _nameController.text.trim(),
      objective: _selectedObjective,
      maxDays: _maxDays.toInt(),
      maxTime: _maxTime,
    );

    Navigator.pop(context, preliminaryTraining);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color trainingColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;

    final daysColor = _getIntensityColor(
      _maxDays,
      1,
      7,
      isDarkMode,
      trainingColor,
    );
    final timeColor = _getIntensityColor(
      _maxTime,
      15,
      180,
      isDarkMode,
      trainingColor,
    );

    final bool isDisabled = _isDbEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createTrainingTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Database',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestWgerScreen()),
              );
              _checkDatabase();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isDbEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Database is empty!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'You need to sync exercises before creating a plan.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestWgerScreen(),
                            ),
                          );
                          _checkDatabase();
                        },
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Sync Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.trainingName,
                  prefixIcon: Icon(Icons.fitness_center, color: trainingColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: trainingColor, width: 2),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 32),
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
                      trainingColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      'strength',
                      l10n.strength,
                      'assets/icons/strength.svg',
                      theme,
                      trainingColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObjectiveButton(
                      'endurance',
                      l10n.endurance,
                      'assets/icons/endurance.svg',
                      theme,
                      trainingColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildSliderLabel(l10n.maxDaysLabel(_maxDays.toInt()), daysColor),
              Slider(
                value: _maxDays,
                min: 1,
                max: 7,
                divisions: 6,
                activeColor: daysColor,
                inactiveColor: daysColor.withValues(alpha: 0.2),
                onChanged: (v) => setState(() => _maxDays = v),
              ),
              const SizedBox(height: 32),
              _buildSliderLabel(l10n.maxTimeLabel(_maxTime.toInt()), timeColor),
              Slider(
                value: _maxTime,
                min: 15,
                max: 180,
                divisions: 11,
                activeColor: timeColor,
                inactiveColor: timeColor.withValues(alpha: 0.2),
                onChanged: (v) => setState(() => _maxTime = v),
              ),
              const SizedBox(height: 48),

              // AQUÍ INTEGRAMOS EL NUEVO COMPONENTE
              PrimaryGradientButton(
                onTap: _submitTrainingConfiguration,
                primaryColor: trainingColor,
                isDisabled: isDisabled,
                child: Text(
                  l10n.createButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? trainingColor : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    Color trainingColor,
  ) {
    final isSelected = _selectedObjective == value;

    return InkWell(
      onTap: () => setState(() => _selectedObjective = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? trainingColor.withValues(alpha: 0.1)
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? trainingColor
                : theme.dividerColor.withValues(alpha: 0.1),
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
                isSelected ? trainingColor : theme.hintColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? trainingColor : theme.hintColor,
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
