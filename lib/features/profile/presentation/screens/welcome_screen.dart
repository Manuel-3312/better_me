import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'choose_profile_screen.dart';

/// The initial screen presented to the user upon launching the application.
/// It provides a centralized language dropdown toggle and relies on an
/// upward swipe gesture to proceed to the core application flow.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access localized strings dynamically based on the current system locale.
    final l10n = AppLocalizations.of(context)!;

    // GestureDetector captures physical touch events like swiping.
    return GestureDetector(
      // Detects the end of a vertical drag (swipe) gesture.
      onVerticalDragEnd: (details) {
        // A negative primaryVelocity indicates an upward swipe direction.
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Replace the WelcomeScreen in the navigation stack so the user
          // cannot return to it via the hardware back button.
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ChooseProfileScreen(),
              // Custom transition to slide the next screen upwards smoothly.
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeOut;

                // Explicitly typed as Tween<Offset> to prevent compiler type errors.
                final tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: Scaffold(
        // Set a full screen background color matching the application theme.
        backgroundColor: Colors.green.shade50,
        body: SafeArea(
          child: Stack(
            children: [
              // Main centered content containing logo, title, and the language dropdown.
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Application Logo Placeholder
                    const Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),

                    // Welcome Title
                    Text(
                      l10n.welcomeTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Language Dropdown Selector
                    const _LanguageDropdown(),
                  ],
                ),
              ),

              // Swipe up instruction anchored to the bottom of the screen.
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const Icon(
                      Icons.keyboard_double_arrow_up,
                      size: 40,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.swipeToStart,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A private widget that renders a styled dropdown menu to toggle the app's language.
/// It interacts directly with the root state (BetterMeApp) to dynamically update the locale.
class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context) {
    // Determine the current language code to set the active dropdown value.
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Hide the default underline of the DropdownButton for a cleaner UI.
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Define the available language options with their respective flag emojis.
          items: const [
            DropdownMenuItem(
              value: 'es',
              child: Row(
                children: [
                  Text('🇪🇸', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text('Español', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Text('🇬🇧', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text('English', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
          ],
          // Handle the language change event.
          onChanged: (String? newLocale) {
            if (newLocale != null && newLocale != currentLocale) {
              BetterMeApp.setLocale(context, Locale(newLocale));
            }
          },
        ),
      ),
    );
  }
}