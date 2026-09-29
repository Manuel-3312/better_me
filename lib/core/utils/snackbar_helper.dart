import 'package:flutter/material.dart';

/// Utility class responsible for managing standardized SnackBar notifications.
/// It ensures visual consistency and theme adaptation across the application.
class SnackbarHelper {
  const SnackbarHelper._();

  /// Displays an interactive SnackBar with an "Undo" action.
  ///
  /// Returns a [ScaffoldMessengerState] to allow the caller to await
  /// the [SnackBarClosedReason].
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  showUndoSnackbar({
    required BuildContext context,
    required String message,
    required String undoLabel,
    VoidCallback? onUndo,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Clear any existing snackbars to prevent overlapping
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onInverseSurface),
        ),
        backgroundColor: colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: undoLabel.toUpperCase(),
          textColor: colorScheme.inversePrimary,
          onPressed: onUndo ?? () {},
        ),
      ),
    );
  }
}
