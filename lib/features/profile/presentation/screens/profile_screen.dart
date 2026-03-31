import 'dart:math';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/profile/presentation/screens/choose_profile_screen.dart';

/// Screen responsible for displaying user biometrics and handling account actions.
/// Now features a "Night Mode" toggle and account management options.
class ProfileScreen extends StatefulWidget {
  final Profile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile _currentProfile;
  final ProfileRepository _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  /// Re-fetches the profile from the database to ensure biometrics are up to date.
  Future<void> _refreshProfileData() async {
    if (_currentProfile.idProfile == null) return;

    final updated = await _repository.getProfileById(
      _currentProfile.idProfile!,
    );
    if (updated != null && mounted) {
      setState(() {
        _currentProfile = updated;
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double _calculateBMI(double weight, double heightCm) {
    final heightMeters = heightCm / 100;
    return weight / pow(heightMeters, 2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final age = _calculateAge(_currentProfile.birthDate);
    final bmiString = _calculateBMI(
      _currentProfile.weight,
      _currentProfile.height,
    ).toStringAsFixed(1);

    // Check if Dark Mode is currently active
    final isDarkMode = BetterMeApp.getTheme(context) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Biometric Summary Card
            _buildSummaryCard(context, l10n, age, bmiString),

            const SizedBox(height: 32),

            // 2. Settings Section Title
            const Text(
              'AJUSTES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Night Mode Toggle Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Modo Noche',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.amber : Colors.blueGrey,
                ),
                value: isDarkMode,
                onChanged: (bool value) {
                  // Updates the global theme state in main.dart
                  BetterMeApp.setTheme(
                    context,
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 4. Account Actions Title
            const Text(
              'CUENTA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // 5. Switch Profile Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChooseProfileScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.switch_account_outlined),
              label: const Text('Cambiar de Perfil'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 6. App Version Info
            Center(
              child: Text(
                'BetterMe AI - v1.0.0',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.welcomeUser(_currentProfile.name),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: l10n.editProfile,
                onPressed: () async {
                  final bool? wasUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProfileScreen(profile: _currentProfile),
                    ),
                  );

                  if (wasUpdated == true) {
                    _refreshProfileData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn(l10n.ageLabel(age), Icons.cake),
              _buildMetricColumn(
                '${_currentProfile.weight} kg',
                Icons.monitor_weight,
              ),
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
}
