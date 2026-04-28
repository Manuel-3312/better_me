import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/core/database/database_helper.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'package:better_me/features/profile/presentation/screens/choose_profile_screen.dart';
import 'package:better_me/features/auth/presentation/screens/auth_screen.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'database_seeder.dart';
import 'package:better_me/features/profile/data/cloud_sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionTile(
            context: context,
            icon: Icons.people_outline,
            title: l10n.switchProfile,
            color: theme.colorScheme.primary,
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
            icon: Icons.translate,
            title: l10n.changeLanguage,
            color: const Color(0xFF0052FF),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLocale,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                items: const [
                  DropdownMenuItem(value: 'es', child: Text('🇪🇸 ES')),
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 EN')),
                ],
                onChanged: (String? newLocale) async {
                  if (newLocale != null) {
                    BetterMeApp.setLocale(context, Locale(newLocale));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newLocale == 'es'
                            ? 'Sincronizando base de datos de ejercicios...'
                            : 'Syncing exercise database...'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    await CloudSyncService().syncExerciseCatalog();
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: _buildInfoCard(theme, l10n.languageWarning),
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
          const SizedBox(height: 32),
          _buildActionTile(
            context: context,
            icon: Icons.cloud_upload,
            title: 'Migrar API Wger (Dev)',
            color: Colors.teal,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Iniciando migración...')),
              );

              await DatabaseSeeder.populateSupabaseFromWger();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Migración completada')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.logout,
            title: l10n.logout,
            color: Colors.redAccent,
            onTap: () async {
              final bool confirm = await DialogHelper.showDeleteConfirmation(
                context: context,
                title: l10n.logoutTitle,
                content: l10n.logoutContent,
                cancelText: l10n.cancel,
                deleteText: l10n.logout,
              );

              if (!confirm) return;

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('last_profile_id');

              final db = await DatabaseHelper.instance.database;
              await db.delete('profile');
              await db.delete('diet');
              await db.delete('training');
              await db.delete('weight_history');
              await db.delete('progress_entries');

              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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