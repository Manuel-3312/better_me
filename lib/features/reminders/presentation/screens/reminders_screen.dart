import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/reminders/domain/models/reminder.dart';
import 'package:better_me/core/services/notification_service.dart';
import 'package:better_me/core/services/preferences_services.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';

/// Screen responsible for displaying and managing daily reminders.
///
/// Utilizes NotificationService for scheduling local push notifications
/// and PreferencesService for persisting user reminder data.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const String _remindersPrefsKey = 'user_reminders_data';

  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServicesAndData();
  }

  /// Initializes required services and loads persisted reminders.
  Future<void> _initializeServicesAndData() async {
    await _notificationService.initialize();
    await _loadReminders();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Retrieves saved reminders from local preferences.
  Future<void> _loadReminders() async {
    try {
      final String? storedData = await PreferencesService.getString(
        _remindersPrefsKey,
      );
      if (storedData != null && storedData.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(storedData);
        _reminders =
            decodedList.map((item) => Reminder.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      _reminders = [];
    }
  }

  /// Persists the current list of reminders to local preferences.
  Future<void> _saveReminders() async {
    try {
      final String encodedData = jsonEncode(
        _reminders.map((reminder) => reminder.toJson()).toList(),
      );
      await PreferencesService.setString(_remindersPrefsKey, encodedData);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
    }
  }

  /// Toggles the active state of a reminder, updating persistence and notifications.
  Future<void> _toggleReminder(int index, bool isEnabled) async {
    setState(() {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
    });

    final currentReminder = _reminders[index];
    final notificationId = currentReminder.id.hashCode;

    if (isEnabled) {
      await _notificationService.scheduleDailyReminder(
        id: notificationId,
        title: currentReminder.title,
        body: currentReminder.description ?? '',
        hour: currentReminder.hour,
        minute: currentReminder.minute,
      );
    } else {
      await _notificationService.cancelReminder(notificationId);
    }

    await _saveReminders();
  }

  /// Deletes a reminder, cancels its notification, and updates persistence.
  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    final notificationId = reminder.id.hashCode;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _reminders.removeAt(index);
    });

    await _notificationService.cancelReminder(notificationId);
    await _saveReminders();

    if (mounted) {
      SnackbarHelper.showUndoSnackbar(
        context: context,
        message: l10n.reminderDeleted,
        undoLabel: l10n.undo,
        onUndo: () async {
          setState(() {
            _reminders.insert(index, reminder);
          });
          if (reminder.isEnabled) {
            await _notificationService.scheduleDailyReminder(
              id: notificationId,
              title: reminder.title,
              body: reminder.description ?? '',
              hour: reminder.hour,
              minute: reminder.minute,
            );
          }
          await _saveReminders();
        },
      );
    }
  }

  /// Opens a dialog to create a new reminder.
  Future<void> _showAddReminderDialog() async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(l10n.newReminder),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        hintText: l10n.titleHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                        hintText: l10n.descriptionHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.time),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedTime.format(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                PrimaryGradientButton(
                  primaryColor: theme.colorScheme.primary,
                  onTap: () => Navigator.pop(context, true),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && titleController.text.isNotEmpty && mounted) {
      final newReminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        description:
        descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );

      setState(() {
        _reminders.add(newReminder);
      });

      await _notificationService.scheduleDailyReminder(
        id: newReminder.id.hashCode,
        title: newReminder.title,
        body: newReminder.description ?? '',
        hour: newReminder.hour,
        minute: newReminder.minute,
      );

      await _saveReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.dailyReminders,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? _buildEmptyState(theme, l10n)
          : _buildRemindersList(theme, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the placeholder state when no reminders exist.
  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: theme.hintColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRemindersSet,
            style: TextStyle(fontSize: 16, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of active and inactive reminders.
  Widget _buildRemindersList(ThemeData theme, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final timeString = TimeOfDay(
          hour: reminder.hour,
          minute: reminder.minute,
        ).format(context);

        return Dismissible(
          key: Key(reminder.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _deleteReminder(index),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                reminder.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  reminder.description != null &&
                      reminder.description!.isNotEmpty
                      ? '$timeString • ${reminder.description}'
                      : timeString,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
              trailing: Switch(
                value: reminder.isEnabled,
                onChanged: (value) => _toggleReminder(index, value),
                activeThumbColor: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}