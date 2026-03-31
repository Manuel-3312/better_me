import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'choose_profile_screen.dart';

/// A unified entry screen that combines a high-fidelity SVG animation
/// with the core welcome interactions (language selection and swipe navigation).
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawingAnimation;
  late Animation<double> _starFadeAnimation;
  late Animation<double> _starScaleAnimation;

  /// Controls the visibility of the interactive Welcome UI after the logo finishes.
  bool _showWelcomeUI = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _drawingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
      ),
    );

    _starFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.8, curve: Curves.easeIn),
      ),
    );

    _starScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.2),
            weight: 70,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.2, end: 1.0),
            weight: 30,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 0.9, curve: Curves.elasticOut),
          ),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showWelcomeUI = true;
        });
      }
    });

    _controller.forward();
  }

  /// Handles the upward swipe gesture to transition to the Profile Selection.
  /// Handles the transition to the Profile Selection screen.
  /// Implements a "Reveal" transition that mimics removing a physical cover.
  void _onSwipeUp(BuildContext context) {
    if (!_showWelcomeUI) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        // 500ms provides a snappier, more "mechanical" feel for a cover removal
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const ChooseProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          /// The 'easeOutQuart' curve mimics the physics of a fast-moving
          /// object slowing down quickly once the "pull" is released.
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          );

          /// Vertical offset starting from the bottom (1.0) to the center (0.0).
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return SlideTransition(
            position: slideTween,
            child: Container(
              /// Adding a subtle shadow at the top of the incoming screen
              /// enhances the "layer" effect, making it look like a physical cover.
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          _onSwipeUp(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000814),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. The Animated Logo Layer
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: SvgLogoPainter(
                          drawingPercent: _drawingAnimation,
                          starOpacity: _starFadeAnimation,
                          starScale: _starScaleAnimation,
                        ),
                      ),
                    ),

                    // 2. Welcome Text (Fades in after logo)
                    AnimatedOpacity(
                      opacity: _showWelcomeUI ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            l10n.welcomeTitle,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _LanguageDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Swipe Instructions (Anchored to Bottom)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showWelcomeUI ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.keyboard_double_arrow_up,
                        size: 32,
                        color: Color(0xFF0052FF),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.swipeToStart,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A styled dropdown for language selection optimized for a dark background.
class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale,
          icon: const Icon(Icons.translate, color: Color(0xFF0052FF), size: 18),
          dropdownColor: const Color(0xFF000814),
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          items: const [
            DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
            DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
          ],
          onChanged: (String? newLocale) {
            if (newLocale != null) {
              BetterMeApp.setLocale(context, Locale(newLocale));
            }
          },
        ),
      ),
    );
  }
}

/// CustomPainter that renders the sequential SVG tracing animation.
class SvgLogoPainter extends CustomPainter {
  final Animation<double> drawingPercent;
  final Animation<double> starOpacity;
  final Animation<double> starScale;

  SvgLogoPainter({
    required this.drawingPercent,
    required this.starOpacity,
    required this.starScale,
  }) : super(repaint: drawingPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final double sc = size.width / 100;

    final mainPaint = Paint()
      ..color = const Color(0xFF0052FF)
      ..strokeWidth = 2.0 * sc
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final neonPaint = Paint()
      ..color = const Color(0xFF0052FF).withValues(alpha: 0.4)
      ..strokeWidth = 4.0 * sc
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(10 * sc, 65 * sc);
    path.lineTo(25 * sc, 65 * sc);
    path.lineTo(32 * sc, 40 * sc);
    path.lineTo(40 * sc, 85 * sc);
    path.lineTo(48 * sc, 65 * sc);
    path.lineTo(55 * sc, 65 * sc);
    path.cubicTo(70 * sc, 65 * sc, 80 * sc, 55 * sc, 88 * sc, 25 * sc);

    final ui.PathMetrics metrics = path.computeMetrics();
    for (final ui.PathMetric metric in metrics) {
      final animatedPath = metric.extractPath(
        0.0,
        metric.length * drawingPercent.value,
      );
      canvas.drawPath(animatedPath, neonPaint);
      canvas.drawPath(animatedPath, mainPaint);
    }

    if (starOpacity.value > 0) {
      final starPaint = Paint()
        ..color = const Color(0xFF0052FF).withValues(alpha: starOpacity.value)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(88 * sc, 23.5 * sc);
      canvas.rotate(math.pi / 3);
      canvas.scale(starScale.value);
      canvas.translate(-88 * sc, -23.5 * sc);

      final starPath = Path();
      starPath.moveTo(88 * sc, 10 * sc);
      starPath.lineTo(90.5 * sc, 21 * sc);
      starPath.lineTo(101 * sc, 23.5 * sc);
      starPath.lineTo(90.5 * sc, 26 * sc);
      starPath.lineTo(88 * sc, 37 * sc);
      starPath.lineTo(85.5 * sc, 26 * sc);
      starPath.lineTo(75 * sc, 23.5 * sc);
      starPath.lineTo(85.5 * sc, 21 * sc);
      starPath.close();

      canvas.drawPath(starPath, starPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SvgLogoPainter oldDelegate) => true;
}
