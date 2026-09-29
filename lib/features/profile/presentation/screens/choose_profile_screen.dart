import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';
import 'package:better_me/features/home/presentation/screens/main_screen.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/profile/presentation/controllers/choose_profile_controller.dart';

/// Screen responsible for displaying a list of previously created profiles.
class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});

  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  late final ChooseProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChooseProfileController();
    _controller.loadProfiles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Profile profile, int index) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: l10n.deleteProfileTitle,
      content: l10n.deleteProfileContent(profile.name),
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || !mounted) return;

    _controller.removeProfileLocally(index);

    final snackBarController = SnackbarHelper.showUndoSnackbar(
      context: context,
      message: l10n.profileDeleted,
      undoLabel: l10n.undo,
    );

    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      _controller.restoreProfileLocally(index, profile);
    } else if (profile.idProfile != null) {
      await _controller.deleteProfilePermanently(profile.idProfile!);
    }
  }

  Future<void> _handleProfileSelection(Profile profile) async {
    if (profile.idProfile != null) {
      await _controller.saveActiveProfileSession(profile.idProfile!);
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(profile: profile)),
          (route) => false,
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(child: Text('Error: ${_controller.error}'));
          }

          if (_controller.profiles.isEmpty) {
            return Center(
              child: Text(
                l10n.noProfilesMessage,
                style: TextStyle(fontSize: 16, color: theme.hintColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.profiles.length,
            itemBuilder: (context, index) {
              final profile = _controller.profiles[index];
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
                        onPressed: () => _confirmDelete(profile, index),
                        tooltip: l10n.delete,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                  onTap: () => _handleProfileSelection(profile),
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
          _controller.loadProfiles();
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