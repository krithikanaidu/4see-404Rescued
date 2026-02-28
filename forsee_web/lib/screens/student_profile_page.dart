import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Import your other pages like this in your real project:
import 'report_page.dart';
import 'quiz_start_page.dart';

void main() {
  runApp(const StudentProfilePage());
}

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4see — Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ProfilePage(),
    );
  }
}

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg        = Color(0xFF2E1118);
const _sidebar   = Color(0xFF200B10);
const _card      = Color(0xFF3E1E28);
const _cardHover = Color(0xFF4E2A34);
const _rose      = Color(0xFFD4899A);
const _roseLight = Color(0xFFF2C4CE);
const _accent    = Color(0xFFFFD6DF);
const _text      = Color(0xFFF8E8EC);
const _textDim   = Color(0xFFAA7888);
const _green     = Color(0xFF7BC67E);
const _teal      = Color(0xFF8ECFC9);

// ─── App Shell with Navigator ─────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  int _navIndex = 0; // 0=Profile, 1=Report, 2=MyMind
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _navigate(int index) {
    setState(() => _navIndex = index);
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _SideNav(selected: _navIndex, onSelect: _navigate),
          Expanded(
            child: FadeTransition(
              opacity: _fadeCtrl,
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_navIndex) {
      case 0:
        return _ProfileContent(slideCtrl: _slideCtrl);
      case 1:
        // In your real project replace with: return const ReportPage();
        return _PlaceholderPage(
          icon: Icons.bar_chart_rounded,
          title: 'Report',
          subtitle: 'Connected to report_page.dart',
          color: _rose,
        );
      case 2:
        // In your real project replace with: return const QuizStartScreen();
        return _PlaceholderPage(
          icon: Icons.psychology_outlined,
          title: 'My Mind & Mood',
          subtitle: 'Connected to quiz_start_page.dart',
          color: _teal,
        );
      default:
        return _ProfileContent(slideCtrl: _slideCtrl);
    }
  }
}

// ─── Side Navigation ──────────────────────────────────────────────────────────
class _SideNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _SideNav({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: _sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_rose, Color(0xFF8B2240)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: _rose.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: Text('4s', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('4see', style: TextStyle(
                color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w900, letterSpacing: -0.5,
              )),
            ]),
          ),

          // Nav Items
          _NavItem(icon: Icons.person_outline_rounded,  label: 'My Profile',    index: 0, selected: selected, onTap: onSelect),
          _NavItem(icon: Icons.bar_chart_rounded,        label: 'Report',        index: 1, selected: selected, onTap: onSelect),
          _NavItem(icon: Icons.psychology_outlined,      label: 'My Mind & Mood',index: 2, selected: selected, onTap: onSelect),

          const Spacer(),

          // Bottom user badge
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(children: [
              _Avatar(size: 36),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Rohan Sharma', style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700)),
                const Text('Class X A', style: TextStyle(color: _textDim, fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.selected, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: sel
                ? _rose.withOpacity(0.18)
                : _hovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: sel
                ? Border.all(color: _rose.withOpacity(0.3))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(children: [
            Icon(widget.icon, color: sel ? _roseLight : _textDim, size: 18),
            const SizedBox(width: 12),
            Text(widget.label, style: TextStyle(
              color: sel ? _roseLight : _textDim,
              fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
            )),
            if (sel) ...[
              const Spacer(),
              Container(width: 6, height: 6,
                decoration: const BoxDecoration(color: _rose, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─── Profile Content ──────────────────────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final AnimationController slideCtrl;
  const _ProfileContent({required this.slideCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.6, -0.4),
          radius: 1.2,
          colors: [Color(0xFF4A1F2C), Color(0xFF2E1118)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final wide = constraints.maxWidth > 800;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
                    .animate(CurvedAnimation(parent: slideCtrl, curve: Curves.easeOutCubic)),
                child: Row(children: [
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('My Profile', style: TextStyle(
                      color: _text, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1,
                    )),
                    SizedBox(height: 4),
                    Text('Student Dashboard  ·  4see Platform', style: TextStyle(color: _textDim, fontSize: 13)),
                  ]),
                  const Spacer(),
                  _TopBadge(Icons.circle, _green, 'Active'),
                  const SizedBox(width: 12),
                  _TopBadge(Icons.calendar_today_outlined, _rose, 'Term 2 · 2024'),
                ]),
              ),
              const SizedBox(height: 40),
              // Main layout
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: profile card
                    SizedBox(width: 280, child: _ProfileCard(slideCtrl: slideCtrl)),
                    const SizedBox(width: 28),
                    // Right: info + stats
                    Expanded(child: _InfoColumn(slideCtrl: slideCtrl)),
                  ],
                )
              else
                Column(children: [
                  _ProfileCard(slideCtrl: slideCtrl),
                  const SizedBox(height: 24),
                  _InfoColumn(slideCtrl: slideCtrl),
                ]),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _TopBadge(this.icon, this.color, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 9),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: _textDim, fontSize: 12)),
    ]),
  );
}

// ─── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final AnimationController slideCtrl;
  const _ProfileCard({required this.slideCtrl});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: slideCtrl, curve: const Interval(0.1, 1, curve: Curves.easeOutCubic))),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Avatar with ring
            Stack(alignment: Alignment.center, children: [
              // Decorative rings
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _rose.withOpacity(0.2), width: 2),
                ),
              ),
              Container(
                width: 104, height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _rose.withOpacity(0.4), width: 2),
                ),
              ),
              _Avatar(size: 90),
              // Online dot
              Positioned(
                right: 16, bottom: 16,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: _green, shape: BoxShape.circle,
                    border: Border.all(color: _card, width: 3),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            const Text('Rohan Sharma', style: TextStyle(
              color: _text, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            )),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _rose.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _rose.withOpacity(0.25)),
              ),
              child: const Text('Class X  ·  Section A', style: TextStyle(color: _rose, fontSize: 12)),
            ),
            const SizedBox(height: 28),
            // Attendance meter
            _AttendanceMeter(76),
            const SizedBox(height: 28),
            // Quick action buttons
            _ActionBtn(Icons.bar_chart_rounded, 'View Report', _rose),
            const SizedBox(height: 10),
            _ActionBtn(Icons.psychology_outlined, 'Mind & Mood', _teal),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;
  const _Avatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7A3A4A), Color(0xFF4A1F2C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: _rose.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Text(
          'RS',
          style: TextStyle(
            color: _roseLight,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.28,
          ),
        ),
      ),
    );
  }
}

class _AttendanceMeter extends StatelessWidget {
  final int percent;
  const _AttendanceMeter(this.percent);

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80 ? _green : percent >= 60 ? _rose : const Color(0xFFE07070);
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Attendance', style: TextStyle(color: _textDim, fontSize: 12)),
        Text('$percent%', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 8),
      Stack(children: [
        Container(height: 8, decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(4),
        )),
        FractionallySizedBox(
          widthFactor: percent / 100,
          child: Container(height: 8, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
          )),
        ),
      ]),
    ]);
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionBtn(this.icon, this.label, this.color);

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _hovered ? widget.color.withOpacity(0.2) : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(_hovered ? 0.5 : 0.2)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, color: widget.color, size: 16),
          const SizedBox(width: 8),
          Text(widget.label, style: TextStyle(color: widget.color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ─── Info Column ──────────────────────────────────────────────────────────────
class _InfoColumn extends StatelessWidget {
  final AnimationController slideCtrl;
  const _InfoColumn({required this.slideCtrl});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: slideCtrl, curve: const Interval(0.15, 1, curve: Curves.easeOutCubic))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(),
          const SizedBox(height: 20),
          _StatsRow(),
          const SizedBox(height: 20),
          _QuickNavCards(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Name',       'Rohan Sharma'],
      ['Date of Birth', '12 Aug 2008'],
      ['Roll No',    '24'],
      ['Class',      'X  ·  Section A'],
      ['School',     'Delhi Public School'],
      ['Email',      'rohan.sharma@dps.edu'],
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _rose.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_outline_rounded, color: _rose, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Student Information', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 24),
          ...rows.asMap().entries.map((e) => _InfoRow(e.value[0], e.value[1], isLast: e.key == rows.length - 1)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Text(label, style: const TextStyle(color: _textDim, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
      if (!isLast)
        Divider(color: Colors.white.withOpacity(0.06), height: 1),
    ]);
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(Icons.favorite_outline, '84%', 'Mental Health', _rose)),
      const SizedBox(width: 16),
      Expanded(child: _StatCard(Icons.school_outlined, '79%', 'Academics', _teal)),
      const SizedBox(width: 16),
      Expanded(child: _StatCard(Icons.event_available_outlined, '76%', 'Attendance', _green)),
    ]);
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard(this.icon, this.value, this.label, this.color);

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? _cardHover : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _hovered ? widget.color.withOpacity(0.3) : Colors.white.withOpacity(0.07)),
          boxShadow: _hovered ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))] : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: widget.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(widget.value, style: TextStyle(color: widget.color, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(widget.label, style: const TextStyle(color: _textDim, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ─── Quick Navigation Cards ───────────────────────────────────────────────────
class _QuickNavCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _QuickNavCard(
          icon: Icons.bar_chart_rounded,
          title: 'View Full Report',
          subtitle: 'Academic · Attendance · Mental Health',
          color: _rose,
          onTap: () {
            //Navigate to report page
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('→ Navigating to report_page.dart'),
                backgroundColor: Color(0xFF4E2A34),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _QuickNavCard(
          icon: Icons.psychology_outlined,
          title: 'My Mind & Mood',
          subtitle: 'Take a quiz · Explore patterns',
          color: _teal,
          onTap: () {
            // Navigate to quiz page
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizStartPage()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('→ Navigating to quiz_start_page.dart'),
                backgroundColor: Color(0xFF1E3A38),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _QuickNavCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickNavCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  State<_QuickNavCard> createState() => _QuickNavCardState();
}

class _QuickNavCardState extends State<_QuickNavCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.18) : _card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _hovered ? widget.color.withOpacity(0.5) : Colors.white.withOpacity(0.07), width: 1.5),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.color.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))]
                : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_hovered ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: const TextStyle(color: _textDim, fontSize: 12)),
              ]),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_hovered ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: widget.color, size: 16),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Placeholder Page (replace with real pages) ───────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _PlaceholderPage({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [color.withOpacity(0.08), _bg],
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: _textDim, fontSize: 14)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              'Replace with your actual page widget',
              style: TextStyle(color: color, fontSize: 13, fontFamily: 'Courier'),
            ),
          ),
        ]),
      ),
    );
  }
}