import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:premium_engneering_app/features/auth/provider/auth_provider.dart';
import 'package:premium_engneering_app/features/auth/provider/auth_state.dart';
import 'package:premium_engneering_app/features/home/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _drop1Scale;
  late Animation<double> _drop2Scale;
  late Animation<double> _drop3Scale;
  late Animation<Offset> _premiumSlide;
  late Animation<double> _premiumOpacity;
  late Animation<Offset> _engSlide;
  late Animation<double> _engOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _progressValue;
  late Animation<double> _shimmerOffset;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Logo drop animations with stagger
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _drop1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );
    _drop2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.35, 0.85, curve: Curves.elasticOut),
      ),
    );
    _drop3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Text animations
    _premiumSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _premiumOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _engSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _engOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _shimmerOffset = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Sequence the animations
    _logoController.forward().then((_) {
      _textController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        _progressController.forward().then((_) {
          Future.delayed(
            const Duration(milliseconds: 400),
            _checkAuthAndNavigate,
          );
        });
      });
    });
  }

  void _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (authProvider.state is AuthAuthenticated) {
      final role = await context.read<AuthRepository>().getUserType();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: role ?? 'role_1'),
        ),
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2570), Color(0xFF2D3B89), Color(0xFF3D4DAA)],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (_, _) => Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              left: -size.width * 0.2,
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (_, _) => Transform.rotate(
                  angle: -_rotateController.value * 2 * math.pi,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Floating particle dots
            ..._buildParticles(size),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo mark
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, _) => FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: _LogoPainter(
                              drop1Scale: _drop1Scale.value,
                              drop2Scale: _drop2Scale.value,
                              drop3Scale: _drop3Scale.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Company name — PREMIUM
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, _) => FadeTransition(
                      opacity: _premiumOpacity,
                      child: SlideTransition(
                        position: _premiumSlide,
                        child: ShaderMask(
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment(_shimmerOffset.value - 1, 0),
                            end: Alignment(_shimmerOffset.value + 1, 0),
                            colors: const [
                              Colors.white,
                              Color(0xFFCCE5FF),
                              Colors.white,
                            ],
                          ).createShader(rect),
                          child: const Text(
                            "PREMIUM",
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ENGINEERING
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, _) => FadeTransition(
                      opacity: _engOpacity,
                      child: SlideTransition(
                        position: _engSlide,
                        child: const Text(
                          "ENGINEERING",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00CEDE),
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, _) => FadeTransition(
                      opacity: _taglineOpacity,
                      child: const Text(
                        "Precision · Quality · Excellence",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          letterSpacing: 2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, _) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              minHeight: 4,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00CEDE),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Loading  ${(_progressValue.value * 100).toInt()}%",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Version tag at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (_, _) => FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    "v1.0.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final positions = [
      [0.1, 0.2],
      [0.85, 0.15],
      [0.2, 0.75],
      [0.9, 0.6],
      [0.5, 0.1],
      [0.7, 0.8],
      [0.05, 0.5],
      [0.95, 0.4],
    ];
    return positions.asMap().entries.map((entry) {
      final i = entry.key;
      final pos = entry.value;
      return Positioned(
        left: size.width * pos[0],
        top: size.height * pos[1],
        child: AnimatedBuilder(
          animation: _rotateController,
          builder: (_, _) {
            final phase = i / positions.length;
            final opacity =
                (math.sin((_rotateController.value + phase) * 2 * math.pi) +
                    1) /
                2;
            return Opacity(
              opacity: opacity * 0.3,
              child: Container(
                width: 4 + (i % 3) * 2.0,
                height: 4 + (i % 3) * 2.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00CEDE),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

/// Custom painter that draws the Premium Engineering logo mark:
/// Three cyan water drops arranged in a pinwheel + one black teardrop
class _LogoPainter extends CustomPainter {
  final double drop1Scale;
  final double drop2Scale;
  final double drop3Scale;

  _LogoPainter({
    required this.drop1Scale,
    required this.drop2Scale,
    required this.drop3Scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 5;
    final r = size.width * 0.22;

    final cyanPaint = Paint()
      ..color = const Color(0xFF1DA7D8)
      ..style = PaintingStyle.fill;
    final blackPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    // White circle background
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.38,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Draw 3 cyan water drops at 120° intervals (top, bottom-left, bottom-right)
    // Drop 1 - top
    if (drop1Scale > 0) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(drop1Scale);
      canvas.translate(-cx, -cy);
      _drawWaterDrop(
        canvas,
        Offset(cx, cy - r * 1.35),
        r * 0.75,
        -math.pi / 2,
        cyanPaint,
      );
      canvas.restore();
    }

    // Drop 2 - bottom-left
    if (drop2Scale > 0) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(drop2Scale);
      canvas.translate(-cx, -cy);
      _drawWaterDrop(
        canvas,
        Offset(cx - r * 1.15, cy + r * 0.65),
        r * 0.75,
        math.pi * 5 / 6,
        cyanPaint,
      );
      canvas.restore();
    }

    // Drop 3 - bottom-right (black)
    if (drop3Scale > 0) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(drop3Scale);
      canvas.translate(-cx, -cy);
      _drawWaterDrop(
        canvas,
        Offset(cx + r * 1.15, cy + r * 0.65),
        r * 0.65,
        math.pi / 6,
        blackPaint,
      );
      canvas.restore();
    }
  }

  void _drawWaterDrop(
    Canvas canvas,
    Offset center,
    double size,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle + math.pi / 2);
    final path = Path();
    // Drop body (circle for bottom)
    path.addOval(
      Rect.fromCircle(center: Offset(0, size * 0.3), radius: size * 0.6),
    );
    // Pointed top
    path.moveTo(0, -size * 0.85);
    path.quadraticBezierTo(-size * 0.5, -size * 0.2, -size * 0.55, size * 0.15);
    path.arcToPoint(
      Offset(size * 0.55, size * 0.15),
      radius: Radius.circular(size * 0.6),
      clockwise: false,
    );
    path.quadraticBezierTo(size * 0.5, -size * 0.2, 0, -size * 0.85);
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.drop1Scale != drop1Scale ||
      old.drop2Scale != drop2Scale ||
      old.drop3Scale != drop3Scale;
}
