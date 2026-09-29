import 'package:flutter/material.dart';

/// A reusable gradient button component standardizing the primary call-to-action
/// visual design across the application. It automatically adapts to the current
/// theme brightness and handles disabled or loading states.
class PrimaryGradientButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color primaryColor;
  final bool isDisabled;
  final bool isLoading;

  const PrimaryGradientButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.primaryColor,
    this.isDisabled = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bool shouldDisable = isDisabled || isLoading || onTap == null;

    return Opacity(
      opacity: shouldDisable ? 0.5 : 1.0,
      child: AbsorbPointer(
        absorbing: shouldDisable,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.8,
                      ),
                      theme.colorScheme.surface.withValues(alpha: 0.9),
                    ]
                  : [primaryColor, primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode
                ? Border.all(color: primaryColor.withValues(alpha: 0.3))
                : null,
            boxShadow: [
              if (!shouldDisable)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: shouldDisable ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: isDarkMode ? primaryColor : Colors.white,
                            ),
                          )
                        : child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
