import 'dart:math';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/presentation/screens/create_profile_screen.dart';

/// The main hub of the application displaying a summary of the selected profile.
/// It calculates and presents biometric data (Age, BMI) and provides navigation
/// access to the core feature modules: Diets and Workouts.
class DashboardScreen extends StatelessWidget {
  /// The active profile passed from the profile selection screen.
  final Profile profile;

  const DashboardScreen({super.key, required this.profile});

  /// Calculates the exact age in years based on the profile's birth date.
  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculates the Body Mass Index (BMI) using weight (kg) and height (cm).
  /// Formula: Weight (kg) / (Height (m))^2
  double _calculateBMI(double weight, double heightCm) {
    final heightMeters = heightCm / 100;
    return weight / pow(heightMeters, 2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Compute biometric data for UI presentation
    final age = _calculateAge(profile.birthDate);
    final bmi = _calculateBMI(profile.weight, profile.height);
    final bmiString = bmi.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Summary Card (Now includes the Edit Button)
              _buildSummaryCard(context, l10n, age, bmiString),
              const SizedBox(height: 32),

              // 2. Action Modules Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModuleCard(
                      context: context,
                      title: l10n.myDiets,
                      icon: Icons.restaurant_menu,
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diets Module / Módulo Dietas'),
                          ),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.myWorkouts,
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Workouts Module / Módulo Entrenamientos',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constructs the top biometric summary card containing user metrics
  /// and the profile edit action button.
  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    int age,
    String bmiString,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Welcome Text + Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.welcomeUser(profile.name),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: l10n.editProfile,
                onPressed: () {
                  // Navigate to the form passing the current profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProfileScreen(profile: profile),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Biometrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn(l10n.ageLabel(age), Icons.cake),
              _buildMetricColumn('${profile.weight} kg', Icons.monitor_weight),
              _buildMetricColumn(
                l10n.bmiLabel(bmiString),
                Icons.health_and_safety,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper widget to display an individual biometric metric with an icon.
  Widget _buildMetricColumn(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Constructs a clickable, stylized card for application modules (Diets/Workouts).
  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
