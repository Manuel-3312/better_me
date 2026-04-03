import 'dart:math';
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/presentation/controllers/profile_controller.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/profile/presentation/screens/choose_profile_screen.dart';
import 'package:better_me/features/profile/presentation/widgets/weight_entry_dialog.dart';
import 'package:better_me/features/progress/presentation/screens/progress_timeline_screen.dart';

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
                _buildProgressBanner(context, theme, profile),
                const SizedBox(height: 24),
                _buildActionList(context, l10n, theme),
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
                          '${profile.weight} kg',
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
                    'Progress Timeline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your body transformation',
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

  Widget _buildActionList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color activeColor = isDarkMode
        ? theme.colorScheme.primary
        : Colors.blueAccent;

    return Column(
      children: [
        _buildActionTile(
          context: context,
          icon: Icons.people_outline,
          title: l10n.switchProfile,
          color: activeColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChooseProfileScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context: context,
          icon: Icons.dark_mode_outlined,
          title: l10n.nightMode,
          color: Colors.deepPurpleAccent,
          trailing: Switch(
            value: isDarkMode,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

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
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      tileColor: theme.cardColor,
    );
  }
}
