import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'role_selection_page.dart';
import 'login_page.dart';

void main() {
  runApp(const LandingPage2());
}

class LandingPage2 extends StatelessWidget {
  const LandingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4see',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  // Brand colors
  static const Color bgColor = Color(0xFF3D1F26);
  static const Color tealColor = Color(0xFF7ECECA);
  static const Color pinkColor = Color(0xFFF2B5C8);
  static const Color greenColor = Color(0xFF6B9E6B);
  static const Color textColor = Color(0xFFF5E6D3);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const SignupPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _goToRoleSelection() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const RoleSelectionPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Decorative blob shapes
          Positioned(top: -30, left: -20, child: _BlobShape(color: greenColor, size: 120, rotation: 0.3)),
          Positioned(top: 20, right: -10, child: _BlobShape(color: pinkColor, size: 100, rotation: -0.5)),
          Positioned(top: 80, right: 30, child: _BlobShape(color: tealColor, size: 60, rotation: 1.2)),
          Positioned(bottom: 180, left: -15, child: _BlobShape(color: pinkColor, size: 110, rotation: 0.8)),
          Positioned(bottom: 80, left: 40, child: _BlobShape(color: greenColor, size: 80, rotation: -0.2)),
          Positioned(bottom: 100, right: -10, child: _BlobShape(color: pinkColor, size: 100, rotation: 0.5)),
          Positioned(bottom: 200, right: 20, child: _BlobShape(color: greenColor, size: 65, rotation: -1.0)),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        _FourSeeButton(
                          label: 'Already have an account?',
                          onTap: _goToLogin,
                          delay: const Duration(milliseconds: 200),
                        ),
                        const SizedBox(height: 16),
                        _FourSeeButton(
                          label: 'Create an account',
                          onTap: _goToRoleSelection,
                          delay: const Duration(milliseconds: 400),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    ),
                    child: SizedBox(
                      height: size.height * 0.35,
                      child: CustomPaint(
                        size: Size(size.width, size.height * 0.35),
                        painter: _IllustrationPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '4',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: pinkColor, height: 1),
              ),
              TextSpan(
                text: 'see',
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w400, color: textColor, height: 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 180, height: 2, color: textColor),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Shared Button Widget
// ─────────────────────────────────────────────
class _FourSeeButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Duration delay;

  const _FourSeeButton({required this.label, required this.onTap, required this.delay});

  @override
  State<_FourSeeButton> createState() => _FourSeeButtonState();
}

class _FourSeeButtonState extends State<_FourSeeButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _entryController;
  late Animation<double> _slideIn;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _slideIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack);
    Future.delayed(widget.delay, () { if (mounted) _entryController.forward(); });
  }

  @override
  void dispose() { _entryController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideIn,
      builder: (context, child) => Transform.scale(scale: _slideIn.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF7ECECA).withOpacity(0.15),
              border: Border.all(color: const Color(0xFF7ECECA), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFFF5E6D3),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFF5E6D3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Blob Shape
// ─────────────────────────────────────────────
class _BlobShape extends StatelessWidget {
  final Color color;
  final double size;
  final double rotation;

  const _BlobShape({required this.color, required this.size, required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(size: Size(size, size), painter: _BlobPainter(color: color)),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final x1 = cx + r * math.cos(angle - 0.4);
      final y1 = cy + r * math.sin(angle - 0.4);
      final x2 = cx + r * 1.1 * math.cos(angle);
      final y2 = cy + r * 1.1 * math.sin(angle);
      final x3 = cx + r * math.cos(angle + 0.4);
      final y3 = cy + r * math.sin(angle + 0.4);
      if (i == 0) path.moveTo(x1, y1); else path.lineTo(x1, y1);
      path.quadraticBezierTo(x2, y2, x3, y3);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => color != old.color;
}

// ─────────────────────────────────────────────
// Illustration Painter
// ─────────────────────────────────────────────
class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    final groundPaint = Paint()..color = const Color(0xFF5A8A6A);
    final groundPath = Path()
      ..moveTo(cx - 120, cy + 20)
      ..quadraticBezierTo(cx - 60, cy - 30, cx, cy - 20)
      ..quadraticBezierTo(cx + 80, cy - 40, cx + 130, cy + 10)
      ..quadraticBezierTo(cx + 60, cy + 60, cx, cy + 50)
      ..quadraticBezierTo(cx - 60, cy + 70, cx - 120, cy + 20);
    canvas.drawPath(groundPath, groundPaint);

    final pantsPaint = Paint()..color = const Color(0xFF4A7EC8);
    final pantsPath = Path()
      ..moveTo(cx - 40, cy - 10)..lineTo(cx - 60, cy + 30)..lineTo(cx - 30, cy + 35)
      ..lineTo(cx - 20, cy + 5)..lineTo(cx, cy + 5)..lineTo(cx + 10, cy + 35)
      ..lineTo(cx + 40, cy + 30)..lineTo(cx + 20, cy - 10)..close();
    canvas.drawPath(pantsPath, pantsPaint);

    final torsoPath = Path()
      ..moveTo(cx - 30, cy - 40)..lineTo(cx - 40, cy)..lineTo(cx + 30, cy)
      ..lineTo(cx + 20, cy - 40)..close();
    canvas.drawPath(torsoPath, Paint()..color = const Color(0xFFE8834A));

    canvas.drawCircle(Offset(cx + 5, cy - 55), 18, Paint()..color = const Color(0xFFF5C5A0));

    final hairPaint = Paint()..color = const Color(0xFFE05080);
    canvas.drawCircle(Offset(cx + 5, cy - 65), 14, hairPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 10, cy - 55), width: 18, height: 22), hairPaint);

    final tabletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 5, cy - 5), width: 55, height: 38),
      const Radius.circular(5),
    );
    canvas.drawRRect(tabletRect, Paint()..color = const Color(0xFF2A2A4A));
    canvas.drawRRect(tabletRect.deflate(3), Paint()..color = const Color(0xFF4A6FD4));

    final cloudPaint = Paint()..color = const Color(0xFF88CCEE);
    canvas.drawCircle(Offset(cx + 70, cy - 50), 30, cloudPaint);
    canvas.drawCircle(Offset(cx + 90, cy - 65), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 55, cy - 60), 20, cloudPaint);

    final shoePaint = Paint()..color = const Color(0xFFFFDD22);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 45, cy + 45), width: 30, height: 16), shoePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy + 42), width: 26, height: 14), shoePaint);

    _drawSparkle(canvas, Offset(cx + 100, cy - 80), 8, const Color(0xFFF2B5C8));
    _drawSparkle(canvas, Offset(cx - 80, cy - 40), 6, const Color(0xFF7ECECA));
    _drawSparkle(canvas, Offset(cx + 110, cy - 20), 5, const Color(0xFF7ECECA));
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color..strokeWidth = 1.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(center, Offset(center.dx + size * math.cos(angle), center.dy + size * math.sin(angle)), paint);
    }
    canvas.drawCircle(center, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => false;
}