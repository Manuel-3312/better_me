import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

// Absolute imports
import 'package:better_me/features/home/presentation/screens/main_screen.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';

/// Screen responsible for displaying a list of previously created profiles.
/// It acts as the gateway to the main application dashboard and allows
/// profile deletion with an undo mechanism, while persisting the chosen session.
class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});

  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  /// Repository instance handling SQLite database operations.
  final ProfileRepository _repository = ProfileRepository();

  /// Future that holds the list of profiles fetched from the local database.
  late Future<List<Profile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  /// Initiates the asynchronous request to fetch all profiles from the database
  /// and updates the UI state.
  void _loadProfiles() {
    setState(() {
      _profilesFuture = _repository.getAllProfiles();
    });
  }

  /// Displays a confirmation dialog before deleting a profile.
  /// If confirmed, it proceeds to delete the profile and offers an undo option.
  Future<void> _confirmDelete(BuildContext context, Profile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.deleteProfileTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(l10n.deleteProfileContent(profile.name)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // Updated to fix the deprecation warning
          backgroundColor: theme.dialogTheme.backgroundColor,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: theme.hintColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      _deleteProfile(profile);
    }
  }

  /// Deletes the profile from the database, refreshes the UI, and displays
  /// a Snackbar with an action to undo the deletion.
  Future<void> _deleteProfile(Profile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Ensure the profile has a valid ID before attempting deletion
    if (profile.idProfile == null) return;

    // 1. Delete from database
    await _repository.deleteProfile(profile.idProfile!);

    // 2. Refresh the list
    _loadProfiles();

    if (!mounted) return;

    // 3. Show Snackbar with Undo action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          textColor: theme.colorScheme.primary,
          onPressed: () async {
            // Re-insert the deleted profile to achieve the "Undo" effect
            await _repository.createProfile(profile);
            _loadProfiles();
          },
        ),
      ),
    );
  }

  /// Handles the selection of a profile, saves the session, and navigates.
  Future<void> _handleProfileSelection(
    BuildContext context,
    Profile profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (profile.idProfile != null) {
      await prefs.setInt('last_profile_id', profile.idProfile!);
    }

    // Safely check if the widget is still mounted before navigating
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.chooseProfileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Profile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                l10n.noProfilesMessage,
                style: TextStyle(fontSize: 16, color: theme.hintColor),
              ),
            );
          }

          final profiles = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    profile.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${profile.weight} kg - ${profile.height} cm',
                    style: TextStyle(color: theme.hintColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.hintColor,
                        ),
                        onPressed: () => _confirmDelete(context, profile),
                        tooltip: l10n.delete,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                  onTap: () => _handleProfileSelection(context, profile),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProfileScreen(),
            ),
          );
          _loadProfiles();
        },
        icon: const Icon(Icons.add),
        label: Text(
          l10n.createProfileButton,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
