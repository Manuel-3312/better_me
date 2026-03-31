import 'dart:math';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/profile/presentation/screens/choose_profile_screen.dart';
import 'package:better_me/features/profile/presentation/widgets/weight_entry_dialog.dart';

// NUEVOS IMPORTS
import 'package:better_me/features/profile/data/weight_repository.dart';
import 'package:better_me/features/profile/domain/models/weight_entry.dart';
import 'package:better_me/features/profile/presentation/widgets/weight_chart_widget.dart';

class ProfileScreen extends StatefulWidget {
  final Profile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile _currentProfile;
  final ProfileRepository _repository = ProfileRepository();

  // Repositorio y lista para la gráfica
  final WeightRepository _weightRepo = WeightRepository();
  List<WeightEntry> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadWeightHistory(); // Carga inicial
  }

  /// Carga el historial de peso desde la base de datos
  Future<void> _loadWeightHistory() async {
    if (_currentProfile.idProfile == null) return;
    final history = await _weightRepo.getWeightHistory(
      _currentProfile.idProfile!,
    );
    if (mounted) {
      setState(() {
        // Invertimos la lista para que la gráfica vaya de pasado a presente (izquierda a derecha)
        _weightHistory = history.reversed.toList();
      });
    }
  }

  /// Fetches the latest profile data and refreshes the chart.
  Future<void> _refreshProfileData() async {
    if (_currentProfile.idProfile == null) return;

    final updated = await _repository.getProfileById(
      _currentProfile.idProfile!,
    );
    if (updated != null && mounted) {
      setState(() {
        _currentProfile = updated;
      });
      _loadWeightHistory(); // También refrescamos la gráfica
    }
  }

  /// Opens the weight logging dialog and refreshes data if a new entry was saved.
  Future<void> _openWeightDialog() async {
    if (_currentProfile.idProfile == null) return;

    final bool? wasUpdated = await showDialog<bool>(
      context: context,
      builder: (context) =>
          WeightEntryDialog(idProfile: _currentProfile.idProfile!),
    );

    if (wasUpdated == true) {
      _refreshProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileCard(context, l10n, theme),

            const SizedBox(height: 24),

            // INSERTAMOS LA GRÁFICA AQUÍ
            WeightChartWidget(data: _weightHistory),

            const SizedBox(height: 24),

            _buildActionList(context, l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final double bmi =
        _currentProfile.weight / pow(_currentProfile.height / 100, 2);
    final String bmiString = bmi.toStringAsFixed(1);
    final int age = DateTime.now().year - _currentProfile.birthDate.year;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white24,
                child: Text(
                  _currentProfile.name.isNotEmpty
                      ? _currentProfile.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentProfile.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _currentProfile.sex == 'M' ? l10n.male : l10n.female,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: l10n.editProfile,
                onPressed: () async {
                  final bool? wasUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProfileScreen(profile: _currentProfile),
                    ),
                  );
                  if (wasUpdated == true) _refreshProfileData();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn(l10n.ageLabel(age), Icons.cake),
              GestureDetector(
                onTap: _openWeightDialog,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, top: 4),
                        child: _buildMetricColumn(
                          '${_currentProfile.weight} kg',
                          Icons.monitor_weight,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildActionList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.people_outline,
          title: l10n.switchProfile,
          color: Colors.blueAccent,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChooseProfileScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.nightMode,
          color: Colors.deepPurpleAccent,
          trailing: Switch(
            value: theme.brightness == Brightness.dark,
            onChanged: (value) {
              BetterMeApp.setTheme(
                context,
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      tileColor: Theme.of(context).cardColor,
    );
  }
}
