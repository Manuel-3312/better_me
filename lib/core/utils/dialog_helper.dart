import 'package:flutter/material.dart';

/// Utility class responsible for rendering standardized and adaptive dialogs.
/// It automatically adjusts its visual language based on the active theme (Light/Dark).
class DialogHelper {
  const DialogHelper._();

  /// Displays a standardized confirmation dialog for destructive actions.
  ///
  /// Utilizes the current [ThemeData.colorScheme] to ensure contrast and
  /// visibility across different display modes.
  ///
  /// Returns [true] if the user confirms, [false] otherwise.
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String deleteText,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          elevation: 3,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: colorScheme.surfaceTint,
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
              child: Text(
                cancelText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                deleteText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}