import 'dart:math';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/presentation/controllers/profile_controller.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/profile/presentation/screens/settings_screen.dart';
import 'package:better_me/features/profile/presentation/widgets/weight_entry_dialog.dart';
import 'package:better_me/features/progress/presentation/screens/progress_timeline_screen.dart';
import 'package:better_me/features/reminders/presentation/screens/reminders_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Profile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.initialize(widget.profile);
    _controller.refreshProfileData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWeightDialog() async {
    final bool? wasUpdated = await showDialog<bool>(
      context: context,
      builder: (context) =>
          WeightEntryDialog(idProfile: _controller.currentProfile.idProfile!),
    );

    if (wasUpdated == true) {
      _controller.refreshProfileData();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final profile = _controller.currentProfile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildProfileCard(context, l10n, theme, profile),
                const SizedBox(height: 24),
                _buildProgressBanner(context, l10n, theme, profile),
                const SizedBox(height: 16),
                _buildRemindersBanner(context, theme, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Profile profile,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color activeColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;

    final double bmi = profile.weight / pow(profile.height / 100, 2);
    final String bmiString = bmi.toStringAsFixed(1);
    final int age = DateTime.now().year - profile.birthDate.year;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.8,
                  ),
                  theme.colorScheme.surface.withValues(alpha: 0.9),
                ]
              : [activeColor, activeColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: isDarkMode
            ? Border.all(color: activeColor.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: isDarkMode
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.white24,
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? activeColor : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                    Text(
                      profile.sex == 'M' ? l10n.male : l10n.female,
                      style: TextStyle(
                        color: isDarkMode ? theme.hintColor : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_note,
                  color: isDarkMode ? activeColor : Colors.white,
                  size: 28,
                ),
                tooltip: l10n.editProfile,
                onPressed: () async {
                  final bool? wasUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProfileScreen(profile: profile),
                    ),
                  );
                  if (wasUpdated == true) _controller.refreshProfileData();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(
            color: isDarkMode
                ? theme.dividerColor.withValues(alpha: 0.1)
                : Colors.white24,
            height: 1,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn(
                l10n.ageLabel(age),
                Icons.cake,
                isDarkMode,
                activeColor,
                theme,
              ),
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
                          l10n.weightDisplay(profile.weight),
                          Icons.monitor_weight,
                          isDarkMode,
                          activeColor,
                          theme,
                        ),
                      ),
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: isDarkMode
                            ? activeColor
                            : Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: isDarkMode
                              ? theme.colorScheme.surface
                              : activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildMetricColumn(
                l10n.bmiLabel(bmiString),
                Icons.health_and_safety,
                isDarkMode,
                activeColor,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    IconData icon,
    bool isDarkMode,
    Color activeColor,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: isDarkMode ? activeColor : Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? theme.colorScheme.onSurface : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBanner(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Profile profile,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    const MaterialColor bannerColor = Colors.teal;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgressTimelineScreen(profile: profile),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? bannerColor.withValues(alpha: 0.15)
              : bannerColor.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bannerColor.withValues(alpha: isDarkMode ? 0.3 : 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_graph_rounded,
                color: isDarkMode ? bannerColor.shade200 : bannerColor.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.progressTimelineTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.trackTransformation,
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersBanner(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    const MaterialColor bannerColor = Colors.orange;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? bannerColor.withValues(alpha: 0.15)
              : bannerColor.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bannerColor.withValues(alpha: isDarkMode ? 0.3 : 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: isDarkMode ? bannerColor.shade200 : bannerColor.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyReminders,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dailyDesc,
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}
