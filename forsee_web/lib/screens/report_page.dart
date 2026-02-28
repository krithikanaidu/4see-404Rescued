import 'dart:math' as math;
import 'package:flutter/material.dart';
//import 'shared_nav.dart';        // ← uncomment in your real project
import 'student_profile_page.dart'; 
import 'quiz_start_page.dart';

void main() {
  runApp(const ReportApp());
}

class ReportApp extends StatelessWidget {
  const ReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Report — Dhruv Rathee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ReportPage(),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

// Aligned with shared_nav.dart palette
const _rose     = Color(0xFFF2C4CE);
const _roseDark = Color(0xFFD4899A);
const _bg       = Color(0xFF2E1118);
const _sidebar  = Color(0xFF200B10);
const _card     = Color(0xFF3E1E28);
const _cardLight= Color(0xFF4E2A34);
const _green    = Color(0xFF7BC67E);
const _red      = Color(0xFFE07070);
const _text     = Color(0xFFF8E8EC);
const _textDim  = Color(0xFFAA7888);
const _accent   = Color(0xFFFFD6DF);

final _courseData = [
  _Bar('Mat', 0.82, _green),
  _Bar('SS', 0.65, _roseDark),
  _Bar('IP', 0.91, _green),
  _Bar('LAN', 0.48, _red),
  _Bar('CS', 0.77, _roseDark),
];

final _attendanceData = [
  _Bar('Jan', 0.90, _green),
  _Bar('Feb', 0.72, _roseDark),
  _Bar('Mar', 0.85, _green),
  _Bar('Apr', 0.60, _red),
  _Bar('May', 0.78, _roseDark),
];

final _insights = [
  _Insight(Icons.psychology_outlined, 'Cognitive Load', 'High focus retention during morning sessions. Consider scheduling demanding subjects before noon.'),
  _Insight(Icons.trending_up, 'Progress Trend', 'Mental health score improved 12% over last month. Consistent quiz participation is a strong predictor.'),
  _Insight(Icons.school_outlined, 'Academic Pattern', 'Strong performance in STEM. Language subjects need additional support. LAN score below threshold.'),
  _Insight(Icons.calendar_today_outlined, 'Attendance Risk', 'April attendance dipped to 60%. Attendance correlates directly with academic performance here.'),
  _Insight(Icons.lightbulb_outline, 'LLM Suggestion', 'Recommend 2x weekly peer study sessions for Language. Past cohorts improved avg. 18% in 6 weeks.'),
  _Insight(Icons.quiz_outlined, 'Quiz Analysis', '7 quizzes taken this term. Accuracy peaks on CS topics. Mental health quizzes show self-awareness growth.'),
];

class _Bar {
  final String label;
  final double value;
  final Color color;
  const _Bar(this.label, this.value, this.color);
}

class _Insight {
  final IconData icon;
  final String title;
  final String body;
  const _Insight(this.icon, this.title, this.body);
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _scoreAnim;
  late AnimationController _barAnim;
  late AnimationController _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scoreAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _barAnim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fadeAnim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  void _switchTab(int t) {
    setState(() => _tab = t);
    _barAnim.forward(from: 0);
    _fadeAnim.forward(from: 0);
  }

  // Handle global nav: 1 = this page, 0 = Profile, 2 = My Mind & Mood
  void _handleNav(int index) {
    if (index == 1) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => index == 0
            ? const _NavPlaceholder('My Profile', 'student_profile_page.dart')
            : const _NavPlaceholder('My Mind & Mood', 'quiz_start_page.dart'),
        // In your real project:
        // index == 0 ? const ProfilePage() : const QuizStartScreen()
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    _barAnim.dispose();
    _fadeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          // Shared App Sidebar (nav index 1 = Report)
          _AppSideNav(currentIndex: 1, onNavigate: _handleNav),
          // Right: sub-tab bar + content
          Expanded(
            child: Column(
              children: [
                _TopBar(tab: _tab, onTab: _switchTab),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildContent(size),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(48, 40, 48, 48),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final wide = constraints.maxWidth > 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(),
            const SizedBox(height: 36),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _mainCard()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _InsightsPanel()),
                ],
              )
            else ...[
              _mainCard(),
              const SizedBox(height: 24),
              _InsightsPanel(),
            ],
          ],
        );
      }),
    );
  }

  Widget _mainCard() {
    switch (_tab) {
      case 0:
        return _MentalHealthCard(anim: _scoreAnim);
      case 1:
        return _BarChartCard(title: 'Courses', subtitle: 'Performance by subject', bars: _courseData, anim: _barAnim);
      case 2:
        return _BarChartCard(title: 'Attendance', subtitle: 'Monthly presence rate', bars: _attendanceData, anim: _barAnim);
      default:
        return const SizedBox();
    }
  }
}

// ─── Shared App Sidebar (identical nav across all 3 pages) ──────────────────

class _AppSideNav extends StatelessWidget {
  final int currentIndex; // 0=Profile, 1=Report, 2=Mind&Mood
  final ValueChanged<int> onNavigate;
  const _AppSideNav({required this.currentIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: _sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_roseDark, Color(0xFF8B2240)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: _roseDark.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('4s', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
              ),
              const SizedBox(width: 12),
              const Text('4see', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ]),
          ),
          _SideNavItem(icon: Icons.person_outline_rounded, label: 'My Profile',     index: 0, selected: currentIndex, onTap: onNavigate),
          _SideNavItem(icon: Icons.bar_chart_rounded,       label: 'Report',         index: 1, selected: currentIndex, onTap: onNavigate),
          _SideNavItem(icon: Icons.psychology_outlined,     label: 'My Mind & Mood', index: 2, selected: currentIndex, onTap: onNavigate),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF7A3A4A), Color(0xFF4A1F2C)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: _roseDark.withOpacity(0.4), width: 1.5),
                ),
                child: const Center(child: Text('DR', style: TextStyle(color: _rose, fontWeight: FontWeight.w900, fontSize: 11))),
              ),
              const SizedBox(width: 10),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dhruv Rathee', style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('#01245', style: TextStyle(color: _textDim, fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  const _SideNavItem({required this.icon, required this.label, required this.index, required this.selected, required this.onTap});

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final sel = widget.selected == widget.index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: sel ? _roseDark.withOpacity(0.18) : _hovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: sel ? Border.all(color: _roseDark.withOpacity(0.3)) : Border.all(color: Colors.transparent),
          ),
          child: Row(children: [
            Icon(widget.icon, color: sel ? _rose : _textDim, size: 18),
            const SizedBox(width: 12),
            Text(widget.label, style: TextStyle(
              color: sel ? _rose : _textDim, fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
            )),
            if (sel) ...[
              const Spacer(),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: _roseDark, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─── Nav Placeholder (swap with real widgets) ─────────────────────────────────

class _NavPlaceholder extends StatelessWidget {
  final String title;
  final String file;
  const _NavPlaceholder(this.title, this.file);

  @override
  Widget build(BuildContext context) {
    final navIdx = title.contains('Mind') ? 2 : title.contains('Profile') ? 0 : 1;
    return Scaffold(
      backgroundColor: _bg,
      body: Row(children: [
        _AppSideNav(
          currentIndex: navIdx,
          onNavigate: (i) => Navigator.pushReplacement(context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => i == 1
                  ? const ReportPage()
                  : _NavPlaceholder(
                      i == 0 ? 'My Profile' : 'My Mind & Mood',
                      i == 0 ? 'StudentProfilePage.dart' : 'QuizStartPage.dart'),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            ),
          ),
        ),
        Expanded(child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _roseDark.withOpacity(0.12), shape: BoxShape.circle,
                border: Border.all(color: _roseDark.withOpacity(0.3), width: 2),
              ),
              child: Icon(
                title.contains('Mind') ? Icons.psychology_outlined : Icons.person_outline_rounded,
                color: _roseDark, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(color: _text, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Replace with: import \'$file\'', style: const TextStyle(color: _textDim, fontSize: 13)),
          ]),
        )),
      ]),
    );
  }
}
// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _TopBar({required this.tab, required this.onTab});

  static const _labels = ['Mental Health', 'Academics', 'Attendance'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: Row(
        children: [
          Row(
            children: List.generate(_labels.length, (i) {
              final sel = tab == i;
              return GestureDetector(
                onTap: () => onTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? _roseDark : _card.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: sel ? _roseDark : Colors.white.withOpacity(0.08),
                    ),
                    boxShadow: sel ? [BoxShadow(color: _roseDark.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      color: sel ? Colors.white : _textDim,
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Row(children: [
              const Icon(Icons.circle, color: _green, size: 7),
              const SizedBox(width: 7),
              Text('Term 2 · 2024', style: TextStyle(color: _textDim, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_roseDark, _card], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: _accent.withOpacity(0.3), width: 2),
          ),
          child: const Center(child: Text('DR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dhruv Rathee', style: TextStyle(color: _text, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('#01245  ·  Grade 11  ·  Section B', style: TextStyle(color: _textDim, fontSize: 13)),
          ],
        ),
        const Spacer(),
        _StatChip(Icons.star_outline, '84%', 'Overall'),
        const SizedBox(width: 12),
        _StatChip(Icons.trending_up, '+12%', 'This Month'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(children: [
        Icon(icon, color: _roseDark, size: 18),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: _textDim, fontSize: 11)),
        ]),
      ]),
    );
  }
}

// ─── Mental Health Card ───────────────────────────────────────────────────────

class _MentalHealthCard extends StatelessWidget {
  final AnimationController anim;
  const _MentalHealthCard({required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.favorite, color: _roseDark, size: 22),
            const SizedBox(width: 10),
            const Text('Mental Health Score', style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: _green.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _green.withOpacity(0.3))),
              child: const Text('Good', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 40),
          Center(
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) => CustomPaint(
                size: const Size(200, 200),
                painter: _ScorePainter(anim.value * 0.84),
                child: SizedBox(
                  width: 200, height: 200,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        '${(anim.value * 84).toInt()}%',
                        style: const TextStyle(color: _text, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
                      ),
                      const Text('of 100', style: TextStyle(color: _textDim, fontSize: 13)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          // Sub metrics
          Row(children: [
            _MiniMetric('Focus', 0.78, _green),
            const SizedBox(width: 16),
            _MiniMetric('Stress', 0.42, _red),
            const SizedBox(width: 16),
            _MiniMetric('Sleep', 0.65, _roseDark),
            const SizedBox(width: 16),
            _MiniMetric('Social', 0.88, _green),
          ]),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: _textDim, fontSize: 11)),
          const SizedBox(height: 8),
          Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  final double progress;
  _ScorePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeW = 18.0;
    final radius = (size.width - strokeW) / 2;

    // Background ring
    canvas.drawCircle(center, radius,
      Paint()..color = Colors.white.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.round);

    // Red arc (background portion)
    final bgPaint = Paint()
      ..color = _red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * (1 - progress), false, bgPaint);

    // Green arc
    final fgPaint = Paint()
      ..color = _green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(_ScorePainter old) => old.progress != progress;
}

// ─── Bar Chart Card ───────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_Bar> bars;
  final AnimationController anim;
  const _BarChartCard({required this.title, required this.subtitle, required this.bars, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: _textDim, fontSize: 12)),
            ]),
            const Spacer(),
            Icon(Icons.arrow_forward, color: _textDim, size: 18),
          ]),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((b) => AnimatedBuilder(
                animation: anim,
                builder: (_, __) => _BarColumn(b, anim.value),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Row(
            children: [
              _LegendDot(_green, 'Good (≥75%)'),
              const SizedBox(width: 20),
              _LegendDot(_roseDark, 'Average (50–74%)'),
              const SizedBox(width: 20),
              _LegendDot(_red, 'Needs Work (<50%)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: _textDim, fontSize: 11)),
  ]);
}

class _BarColumn extends StatelessWidget {
  final _Bar bar;
  final double animVal;
  const _BarColumn(this.bar, this.animVal);

  @override
  Widget build(BuildContext context) {
    final animated = bar.value * animVal;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${(bar.value * 100).toInt()}%',
          style: TextStyle(color: bar.color, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 52,
            height: 160 * animated,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  bar.color,
                  bar.color.withOpacity(0.5),
                ],
              ),
              boxShadow: [BoxShadow(color: bar.color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(bar.label, style: const TextStyle(color: _textDim, fontSize: 13)),
      ],
    );
  }
}

// ─── Insights Panel ───────────────────────────────────────────────────────────

class _InsightsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _roseDark.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: _roseDark, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('AI Insights', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 24),
          ..._insights.asMap().entries.map((e) => _InsightTile(e.value, e.key)),
        ],
      ),
    );
  }
}

class _InsightTile extends StatefulWidget {
  final _Insight insight;
  final int index;
  const _InsightTile(this.insight, this.index);

  @override
  State<_InsightTile> createState() => _InsightTileState();
}

class _InsightTileState extends State<_InsightTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? _cardLight : _cardLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? _roseDark.withOpacity(0.3) : Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _roseDark.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.insight.icon, color: _roseDark, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.insight.title,
                    style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.insight.body,
                    style: TextStyle(color: _textDim, fontSize: 12, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}