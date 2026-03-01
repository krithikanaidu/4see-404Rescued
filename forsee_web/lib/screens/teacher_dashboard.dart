import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'classroom_page.dart';
import 'add_classroom.dart'; // ← ADD THIS IMPORT

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeIn;
  late AnimationController _slideUp;
  int _activeNav = 0;
  int _selectedDay = 27; // today highlighted

  // Brand palette
  static const _bg        = Color(0xFF1A0D10);
  static const _surface   = Color(0xFF2A1520);
  static const _card      = Color(0xFF321A24);
  static const _cardHigh  = Color(0xFF3E2130);
  static const _rose      = Color(0xFFF2C4CE);
  static const _roseMid   = Color(0xFFD4899A);
  static const _teal      = Color(0xFF7ECECA);
  static const _green     = Color(0xFF7BC67E);
  static const _text      = Color(0xFFF8EEF1);
  static const _textDim   = Color(0xFF8A6070);
  static const _border    = Color(0xFF3D2030);

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _slideUp = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _slideUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                children: [
                  _buildTopNav(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 32, 40, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── LEFT MAIN COLUMN ──
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreetingBanner(),
                              const SizedBox(height: 28),
                              _buildAttentionCard(),
                              const SizedBox(height: 36),
                              _buildClassroomsSection(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        // ── RIGHT SIDE COLUMN ──
                        SizedBox(
                          width: 300,
                          child: Column(
                            children: [
                              _buildCalendarCard(),
                              const SizedBox(height: 24),
                              _buildRecentActivities(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP NAV
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopNav() {
    final navItems = ['Dashboard', 'Classrooms', 'Students', 'Reports'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900),
                children: [
                  const TextSpan(text: '4', style: TextStyle(color: _rose)),
                  const TextSpan(text: 'see', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),

          // Nav Links
          ...navItems.asMap().entries.map((e) {
            final isActive = _activeNav == e.key;
            return GestureDetector(
              onTap: () => setState(() => _activeNav = e.key),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? _teal : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.poppins(
                      color: isActive ? _text : _textDim,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Right: bell + avatar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Text(
                  'Welcome, Rupali!',
                  style: GoogleFonts.poppins(color: _text, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 14),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: _textDim, size: 20),
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_roseMid, Color(0xFF8B2240)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: _rose.withOpacity(0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Text('R', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GREETING BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildGreetingBanner() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(parent: _slideUp, curve: Curves.easeOutCubic)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: GoogleFonts.poppins(color: _textDim, fontSize: 14, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1),
                  children: [
                    const TextSpan(text: 'Rupali ', style: TextStyle(color: _text)),
                    const TextSpan(text: '👋', style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Saturday, 28 Feb 2026  ·  3 classes today',
                style: GoogleFonts.poppins(color: _textDim, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // Quick stats row
          _QuickStat(label: 'Total Students', value: '84', icon: Icons.people_outline_rounded, color: _teal),
          const SizedBox(width: 14),
          _QuickStat(label: 'Classrooms', value: '3', icon: Icons.class_outlined, color: _rose),
          const SizedBox(width: 14),
          _QuickStat(label: 'Avg. Score', value: '76%', icon: Icons.bar_chart_rounded, color: _green),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ATTENTION CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildAttentionCard() {
    final alerts = [
      _Alert(Icons.warning_amber_rounded, 'Riya Mehta', 'Attendance below 60% this month', _rose),
      _Alert(Icons.trending_down_rounded, 'Arjun Shah', 'Quiz score dropped 18% from last week', const Color(0xFFFFB347)),
      _Alert(Icons.psychology_outlined, 'Dhruv Patel', 'Mental health score flagged — follow up recommended', _teal),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _rose.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: _rose, size: 20),
              ),
              const SizedBox(width: 12),
              Text('ATTENTION', style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w800, color: _text, letterSpacing: 1.5,
              )),
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _rose.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _rose.withOpacity(0.3)),
                ),
                child: Text('${alerts.length} alerts', style: GoogleFonts.poppins(
                  color: _rose, fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ),
              const Spacer(),
              _IconBtn(icon: Icons.refresh_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.tune_rounded, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: alerts.map((a) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: alerts.last == a ? 0 : 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(a.icon, color: a.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(a.name, style: GoogleFonts.poppins(
                            color: _text, fontSize: 13, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(a.message, style: GoogleFonts.poppins(
                      color: _textDim, fontSize: 12, height: 1.5,
                    )),
                    const SizedBox(height: 12),
                    GestureDetector(
                      child: Text('View profile →', style: GoogleFonts.poppins(
                        color: a.color, fontSize: 11, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MY CLASSROOMS  ← UPDATED: added + New Classroom button
  // ─────────────────────────────────────────────────────────────
  Widget _buildClassroomsSection() {
    final classrooms = [
      _ClassroomInfo('Class X A', 'Mathematics', 28, 0.82, _teal),
      _ClassroomInfo('Class IX B', 'Science', 31, 0.67, _rose),
      _ClassroomInfo('Class XI C', 'Computer Science', 25, 0.91, _green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('My Classrooms', style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w800, color: _text,
            )),
            const SizedBox(width: 16),

            // ── ✦ NEW: + Add Classroom Button ──
            _AddClassroomButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddClassroomPage()),
                );
              },
            ),

            const Spacer(),

            // VIEW ALL button (unchanged)
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Text('View all classrooms', style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: const Color(0xFF1A0D10), fontSize: 13,
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: classrooms.map((c) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: classrooms.last == c ? 0 : 20),
              child: HoverableClassroomCard(
                color: _card,
                title: c.name,
                destination: const WebClassroomPage(),
                classroomInfo: c,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CALENDAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildCalendarCard() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const offset = 6;
    const totalDays = 28;
    final highlighted = {3, 10, 17, 24};

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left_rounded, color: _textDim, size: 22),
              Text('February 2026', style: GoogleFonts.poppins(
                color: _text, fontWeight: FontWeight.w700, fontSize: 14,
              )),
              const Icon(Icons.chevron_right_rounded, color: _textDim, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) => SizedBox(
              width: 32,
              child: Center(
                child: Text(d, style: GoogleFonts.poppins(
                  color: _textDim, fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: offset + totalDays,
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox();
              final day = i - offset + 1;
              final isToday = day == _selectedDay;
              final hasEvent = highlighted.contains(day);
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isToday ? _teal : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('$day', style: GoogleFonts.poppins(
                        color: isToday ? const Color(0xFF1A0D10) : _text,
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
                      )),
                      if (hasEvent && !isToday)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4, height: 4,
                            decoration: const BoxDecoration(color: _rose, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // RECENT ACTIVITIES
  // ─────────────────────────────────────────────────────────────
  Widget _buildRecentActivities() {
    final activities = [
      _Activity('Quiz submitted', 'Class X A · 28 students', '2h ago', Icons.quiz_outlined, _teal),
      _Activity('Attendance marked', 'Class IX B · 31 students', '4h ago', Icons.check_circle_outline_rounded, _green),
      _Activity('Announcement posted', 'All classrooms', 'Yesterday', Icons.campaign_outlined, _rose),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent Activities', style: GoogleFonts.poppins(
                color: _text, fontSize: 15, fontWeight: FontWeight.w700,
              )),
              const Spacer(),
              Text('See all', style: GoogleFonts.poppins(
                color: _teal, fontSize: 12, fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 18),
          ...activities.map((a) => _buildActivityTile(a)),
        ],
      ),
    );
  }

  Widget _buildActivityTile(_Activity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(a.icon, color: a.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: GoogleFonts.poppins(
                  color: _text, fontSize: 13, fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text(a.subtitle, style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
          Text(a.time, style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✦ NEW: ADD CLASSROOM BUTTON WIDGET
// ─────────────────────────────────────────────────────────────
class _AddClassroomButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddClassroomButton({required this.onTap});

  @override
  State<_AddClassroomButton> createState() => _AddClassroomButtonState();
}

class _AddClassroomButtonState extends State<_AddClassroomButton> {
  bool _hovered = false;

  static const _rose      = Color(0xFFF2C4CE);
  static const _roseMid   = Color(0xFFD4899A);
  static const _card      = Color(0xFF321A24);
  static const _cardHigh  = Color(0xFF3E2130);
  static const _border    = Color(0xFF3D2030);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? _cardHigh : _card,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _hovered ? _roseMid.withOpacity(0.6) : _border,
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: _rose.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _hovered ? _roseMid : _roseMid.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: _hovered ? const Color(0xFF1A0D10) : _roseMid,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'New Classroom',
                style: GoogleFonts.poppins(
                  color: _hovered ? _rose : _roseMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────
class _Alert {
  final IconData icon;
  final String name;
  final String message;
  final Color color;
  const _Alert(this.icon, this.name, this.message, this.color);
}

class _Activity {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  const _Activity(this.title, this.subtitle, this.time, this.icon, this.color);
}

class _ClassroomInfo {
  final String name, subject;
  final int students;
  final double score;
  final Color accent;
  const _ClassroomInfo(this.name, this.subject, this.students, this.score, this.accent);
}

// ─────────────────────────────────────────────────────────────
// QUICK STAT CHIP
// ─────────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _QuickStat({required this.label, required this.value, required this.icon, required this.color});

  static const _bg      = Color(0xFF321A24);
  static const _border  = Color(0xFF3D2030);
  static const _text    = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(
                color: _text, fontWeight: FontWeight.w800, fontSize: 18,
              )),
              Text(label, style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ICON BUTTON
// ─────────────────────────────────────────────────────────────
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;
  static const _card     = Color(0xFF3E2130);
  static const _cardHigh = Color(0xFF4E2A3C);
  static const _textDim  = Color(0xFF8A6070);
  static const _text     = Color(0xFFF8EEF1);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _hovered ? _cardHigh : _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3D2030)),
          ),
          child: Icon(widget.icon, color: _hovered ? _text : _textDim, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HOVERABLE CLASSROOM CARD
// ─────────────────────────────────────────────────────────────
class HoverableClassroomCard extends StatefulWidget {
  final Color color;
  final String title;
  final Widget destination;
  final _ClassroomInfo classroomInfo;

  const HoverableClassroomCard({
    super.key,
    required this.color,
    required this.title,
    required this.destination,
    required this.classroomInfo,
  });

  @override
  State<HoverableClassroomCard> createState() => _HoverableClassroomCardState();
}

class _HoverableClassroomCardState extends State<HoverableClassroomCard> {
  bool isHovered = false;

  static const _border   = Color(0xFF3D2030);
  static const _cardHigh = Color(0xFF3E2130);
  static const _text     = Color(0xFFF8EEF1);
  static const _textDim  = Color(0xFF8A6070);
  static const _green    = Color(0xFF7BC67E);

  @override
  Widget build(BuildContext context) {
    final c = widget.classroomInfo;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget.destination),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isHovered ? _cardHigh : widget.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovered ? c.accent.withOpacity(0.4) : _border,
              width: isHovered ? 1.5 : 1,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(color: c.accent.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10)),
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                  ]
                : [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.class_rounded, color: c.accent, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(c.name, style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w800, color: _text,
              )),
              const SizedBox(height: 4),
              Text(c.subject, style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: c.score,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation(c.accent),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.people_outline_rounded, color: _textDim, size: 14),
                  const SizedBox(width: 5),
                  Text('${c.students} students', style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
                  const Spacer(),
                  Text('${(c.score * 100).toInt()}% avg', style: GoogleFonts.poppins(
                    color: c.accent, fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}