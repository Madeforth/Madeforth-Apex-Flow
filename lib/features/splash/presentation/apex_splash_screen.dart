import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/shared/design/slate_palette.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/features/shell/apex_app_shell.dart';
import 'package:apexflow/onboarding/presentation/onboarding_screen.dart';
import 'package:apexflow/onboarding/presentation/profile_setup_wizard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/settings/application/theme_mode_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class ApexSplashScreen extends ConsumerStatefulWidget {
  const ApexSplashScreen({super.key});

  @override
  ConsumerState<ApexSplashScreen> createState() => _ApexSplashScreenState();
}

class _ApexSplashScreenState extends ConsumerState<ApexSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animation timelines
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  late Animation<double> _textOpacity;
  late Animation<double> _textLetterSpacing;

  late Animation<double> _shimmerProgress;
  late Animation<double> _auraGlow;

  late Animation<double> _statusOpacity;

  String _statusText = '';
  double _telemetryTime = 0.0;
  Timer? _telemetryTimer;

  String get _languageCode => ref.read(appSettingsProvider).locale.languageCode;

  String _bondingStatusText() => tInline(
    _languageCode,
    'Makineyle bağ kuruluyor...',
    'Bonding with machine...',
    'Verbindung zur Maschine wird hergestellt...',
  );

  String _readyStatusText() => tInline(
    _languageCode,
    'Harmony Motoru hazır.',
    'Harmony Engine ready.',
    'Harmony-Engine bereit.',
  );

  @override
  void initState() {
    super.initState();
    _statusText = _bondingStatusText();
    Future.microtask(
      () => ref.read(showThemeToggleProvider.notifier).state = false,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // 1. Logo Elastic Scale & Fade
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // 2. Neon Aura Glow Pulsing (0.0 to 1.0 back and forth)
    _auraGlow =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.2, end: 1.0),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.6),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
          ),
        );

    // 3. Shimmer reflection sweep progress (left to right)
    _shimmerProgress = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeInOut),
      ),
    );

    // 4. Text Cinematic slide, letter spacing contraction, and fade
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _textLetterSpacing = Tween<double>(begin: 16.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Status message fade
    _statusOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Start background wave telemetry timer for real-time oscillation
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (mounted) {
        setState(() {
          _telemetryTime += 0.04;
        });
      }
    });

    // Change status text halfway through
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _statusText = _readyStatusText();
        });
      }
    });

    // Navigate to shell or onboarding after animation finishes
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    ref.read(showThemeToggleProvider.notifier).state = true;
    final settings = ref.read(appSettingsProvider);
    final locale = settings.locale;
    final strings = AppStrings(locale);

    final currentUser = FirebaseAuth.instance.currentUser;
    final Widget nextScreen;
    if (currentUser != null &&
        currentUser.emailVerified &&
        !settings.onboardingDone) {
      nextScreen = ProfileSetupWizardScreen(strings: strings);
    } else if (settings.onboardingDone) {
      nextScreen = const ApexAppShell();
    } else {
      nextScreen = OnboardingScreen(strings: strings);
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF090E17), // Deep slate black
              Color(0xFF030508), // Pure pitch black
            ],
          ),
        ),
        child: Stack(
          children: [
            // 1. Premium flowing real-time dynamic telemetry curves in background
            Positioned.fill(
              child: CustomPaint(
                painter: ApexTelemetryPainter(
                  progress: (_controller.value * 1.5) % 1.0,
                  time: _telemetryTime,
                ),
              ),
            ),

            // 2. Central Content (Logo & Title)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Aura glow behind the logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radial Glow Aura
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF06B6D4,
                                  ).withValues(alpha: 0.18 * _auraGlow.value),
                                  blurRadius: 40 * _auraGlow.value,
                                  spreadRadius: 10 * _auraGlow.value,
                                ),
                              ],
                            ),
                          ),

                          // Logo Container (elastic scale, fade, rotate)
                          Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Transform.rotate(
                                angle: _logoRotation.value,
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.65),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: [
                                (_shimmerProgress.value - 0.3).clamp(0.0, 1.0),
                                _shimmerProgress.value.clamp(0.0, 1.0),
                                (_shimmerProgress.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.srcOver,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF08131F,
                              ), // Deep Graphite Navy
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title & Subtitle Fade & spacing compression
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(opacity: _textOpacity.value, child: child);
                    },
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _textLetterSpacing,
                          builder: (context, child) {
                            return Text(
                              'Apex Flow',
                              style: TextStyle(
                                color: SlatePalette.cyanAccent, // Cyan 500
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: _textLetterSpacing.value,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MACHINE RELATIONSHIP OS',
                          style: TextStyle(
                            color: context.colors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'developed by Madeforth',
                          style: TextStyle(
                            color: context.colors.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Status text at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56.0),
                child: AnimatedBuilder(
                  animation: _statusOpacity,
                  builder: (context, child) {
                    return Opacity(opacity: _statusOpacity.value, child: child);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            SlatePalette.cyanAccent.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusText.toUpperCase(),
                        style: TextStyle(
                          color: context.colors.muted.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApexTelemetryPainter extends CustomPainter {
  final double progress;
  final double time;

  ApexTelemetryPainter({required this.progress, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // 3 overlapping elegant flow lines
    final cyanPaint = Paint()
      ..color = SlatePalette.cyanAccent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final goldPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = SlatePalette.cyanAccent.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Draw main cyan wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.58);
    path1.cubicTo(
      size.width * 0.28,
      size.height * (0.35 + 0.05 * math.sin(time)),
      size.width * 0.62,
      size.height * (0.78 - 0.05 * math.cos(time)),
      size.width,
      size.height * 0.48,
    );
    canvas.drawPath(path1, cyanPaint);

    // Draw secondary gold wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.48);
    path2.cubicTo(
      size.width * 0.38,
      size.height * (0.72 + 0.06 * math.cos(time * 0.7)),
      size.width * 0.68,
      size.height * (0.32 - 0.06 * math.sin(time * 0.7)),
      size.width,
      size.height * 0.58,
    );
    canvas.drawPath(path2, goldPaint);

    // Draw flowing telemetry data packets along the main cyan path
    final pathMetrics = path1.computeMetrics();
    for (final metric in pathMetrics) {
      for (int i = 0; i < 3; i++) {
        final double dotProgress = (progress + i * 0.33) % 1.0;
        final tangent = metric.getTangentForOffset(metric.length * dotProgress);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2.5, dotPaint);

          // Outer ripple circle around each data packet
          canvas.drawCircle(
            tangent.position,
            5.5,
            Paint()
              ..color = SlatePalette.cyanAccent.withValues(alpha: 0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ApexTelemetryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.time != time;
  }
}
