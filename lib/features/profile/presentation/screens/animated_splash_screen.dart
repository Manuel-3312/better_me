import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/main.dart';
import 'package:better_me/features/profile/data/profile_repository.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/home/presentation/screens/main_screen.dart';
import 'package:better_me/features/profile/presentation/screens/choose_profile_screen.dart';
import 'package:better_me/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/features/auth/data/auth_service.dart';
import 'package:better_me/features/auth/presentation/screens/auth_screen.dart';

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

  bool _showWelcomeUI = false;
  Profile? _lastActiveProfile;
  bool _hasProfiles = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkApplicationState();

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
        if (mounted) {
          setState(() {
            _showWelcomeUI = true;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }

  Future<void> _checkApplicationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getInt('last_profile_id');
      final repository = ProfileRepository();

      if (lastProfileId != null) {
        _lastActiveProfile = await repository.getProfileById(lastProfileId);
      }

      if (_lastActiveProfile == null) {
        final profiles = await repository.getAllProfiles();
        if (mounted) {
          setState(() {
            _hasProfiles = profiles.isNotEmpty;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking application state: $e');
      _hasProfiles = false;
    }
  }

  void _onSwipeUp(BuildContext context) {
    if (!_showWelcomeUI) return;

    Widget targetScreen;

    if (!_authService.isAuthenticated) {
      targetScreen = const AuthScreen();
    } else if (_lastActiveProfile != null) {
      targetScreen = MainScreen(profile: _lastActiveProfile!);
    } else if (_hasProfiles) {
      targetScreen = const ChooseProfileScreen();
    } else {
      targetScreen = const CreateProfileScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
          );

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          );

          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
              );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: SlideTransition(position: slideAnimation, child: child),
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
    final screenHeight = MediaQuery.of(context).size.height;

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
              Positioned(
                top: screenHeight * 0.15,
                left: 0,
                right: 0,
                child: Center(
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: SvgLogoPainter(
                          drawingPercent: _drawingAnimation,
                          starOpacity: _starFadeAnimation,
                          starScale: _starScaleAnimation,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: screenHeight * 0.52,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showWelcomeUI ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Text(
                        l10n.welcomeTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _LanguageSelector(),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showWelcomeUI ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_double_arrow_up,
                      size: 40,
                      color: Color(0xFF0052FF),
                    ),
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

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentLocale,
              icon: const Icon(
                Icons.translate,
                color: Color(0xFF0052FF),
                size: 18,
              ),
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
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l10n.languageWarning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

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
