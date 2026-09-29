import 'package:flutter/material.dart';

class DialogHelper {
  const DialogHelper._();

  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String deleteText,
  }) async {
    final theme = Theme.of(context);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.dialogTheme.backgroundColor,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelText, style: TextStyle(color: theme.hintColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(deleteText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
