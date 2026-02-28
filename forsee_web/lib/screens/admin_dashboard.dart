import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeIn;
  late AnimationController _slideUp;
  int _activeAction = -1;

  // Brand palette
  static const _bg = Color(0xFF1A0D10);
  static const _surface = Color(0xFF22111A);
  static const _card = Color(0xFF2E1820);
  static const _cardHigh = Color(0xFF3A1E28);
  static const _rose = Color(0xFFF2C4CE);
  static const _roseMid = Color(0xFFD4899A);
  static const _raspberry = Color(0xFFD6336C);
  static const _teal = Color(0xFF7ECECA);
  static const _green = Color(0xFF7BC67E);
  static const _amber = Color(0xFFFFB347);
  static const _text = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);
  static const _border = Color(0xFF3D2030);

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _slideUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
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
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 36, 40, 48),
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPageHeader(),
                              const SizedBox(height: 32),
                              _buildStatsRow(),
                              const SizedBox(height: 32),
                              _buildBottomSection(constraints.maxWidth > 800),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SIDEBAR
  // ─────────────────────────────────────────────
  Widget _buildSidebar() {
    final items = [
      _SideItem(Icons.dashboard_rounded, 'Dashboard', true),
      _SideItem(Icons.class_rounded, 'Classes', false),
      _SideItem(Icons.people_rounded, 'Students', false),
      _SideItem(Icons.bar_chart_rounded, 'Reports', false),
      _SideItem(Icons.campaign_rounded, 'Announcements', false),
      _SideItem(Icons.settings_rounded, 'Settings', false),
    ];

    return Container(
      width: 220,
      color: _surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                    children: const [
                      TextSpan(
                        text: '4',
                        style: TextStyle(color: _rose),
                      ),
                      TextSpan(
                        text: 'see',
                        style: TextStyle(color: _text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _raspberry.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _raspberry.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(
                      color: _raspberry,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          ...items.map((item) => _SideNavTile(item: item)),

          const Spacer(),

          // Admin profile card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_raspberry, Color(0xFF8B1240)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _rose.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'SA',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Admin',
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Super User',
                      style: GoogleFonts.poppins(color: _textDim, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Search
          Container(
            width: 340,
            height: 42,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: TextField(
              style: GoogleFonts.poppins(color: _text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search students, classes, reports...',
                hintStyle: GoogleFonts.poppins(color: _textDim, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _textDim,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
          const Spacer(),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'System Online',
                  style: GoogleFonts.poppins(color: _textDim, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: _textDim,
                  size: 18,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _raspberry,
                    shape: BoxShape.circle,
                    border: Border.all(color: _surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PAGE HEADER
  // ─────────────────────────────────────────────
  Widget _buildPageHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideUp, curve: Curves.easeOutCubic)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saturday, 28 Feb 2026  ·  All systems operational',
                style: GoogleFonts.poppins(color: _textDim, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          _TopActionBtn(
            icon: Icons.add_rounded,
            label: 'Add Student',
            color: _teal,
          ),
          const SizedBox(width: 12),
          _TopActionBtn(
            icon: Icons.download_rounded,
            label: 'Export Report',
            color: _card,
            border: true,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      _Stat(
        '124',
        'Total Students',
        Icons.school_rounded,
        _teal,
        '+8 this month',
      ),
      _Stat(
        '5',
        'Active Classes',
        Icons.class_rounded,
        _rose,
        '2 starting today',
      ),
      _Stat(
        '3',
        'Pending Reports',
        Icons.description_rounded,
        _amber,
        'Review needed',
      ),
      _Stat(
        '97%',
        'System Uptime',
        Icons.verified_rounded,
        _green,
        'Last 30 days',
      ),
    ];

    return Row(
      children: stats
          .asMap()
          .entries
          .map(
            (e) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: e.key < stats.length - 1 ? 20 : 0,
                ),
                child: _StatCard(stat: e.value),
              ),
            ),
          )
          .toList(),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM SECTION
  // ─────────────────────────────────────────────
  Widget _buildBottomSection(bool wide) {
    final content = [
      Expanded(flex: 5, child: _buildQuickActions()),
      const SizedBox(width: 24),
      Expanded(flex: 5, child: _buildRecentActivity()),
    ];

    return wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content)
        : Column(
            children: [content[0], const SizedBox(height: 24), content[2]],
          );
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action(
        Icons.grid_view_rounded,
        'Manage Classes',
        'View and edit all classrooms',
        _teal,
      ),
      _Action(
        Icons.person_rounded,
        'Student Directory',
        'Search and manage students',
        _rose,
      ),
      _Action(
        Icons.assessment_rounded,
        'Generate Reports',
        'Export analytics and data',
        _amber,
      ),
      _Action(
        Icons.campaign_rounded,
        'Global Announcements',
        'Broadcast to all users',
        _green,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _raspberry.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _raspberry,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...actions.asMap().entries.map(
            (e) => _ActionTile(
              action: e.value,
              isHovered: _activeAction == e.key,
              onEnter: () => setState(() => _activeAction = e.key),
              onExit: () => setState(() => _activeAction = -1),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RECENT ACTIVITY
  // ─────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final events = [
      _Event(
        "Today, 10:30 AM",
        "Teacher 'Rupali' submitted grades",
        Icons.check_circle_rounded,
        _green,
      ),
      _Event(
        "Today, 9:15 AM",
        "New student enrolled: Rahul Sharma",
        Icons.person_add_rounded,
        _teal,
      ),
      _Event(
        "Yesterday, 2:15 PM",
        "System backup completed",
        Icons.backup_rounded,
        _rose,
      ),
      _Event(
        "Yesterday, 9:00 AM",
        "Attendance report downloaded",
        Icons.download_done_rounded,
        _amber,
      ),
      _Event(
        "Feb 26, 4:00 PM",
        "Global announcement broadcast",
        Icons.campaign_rounded,
        _roseMid,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: _teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'View all',
                style: GoogleFonts.poppins(
                  color: _teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...events.asMap().entries.map(
            (e) => _buildEventTile(e.value, isLast: e.key == events.length - 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(_Event ev, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ev.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(ev.icon, color: ev.color, size: 15),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: _border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.time,
                    style: GoogleFonts.poppins(color: _textDim, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ev.title,
                    style: GoogleFonts.poppins(
                      color: _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class _SideItem {
  final IconData icon;
  final String label;
  final bool active;
  const _SideItem(this.icon, this.label, this.active);
}

class _Stat {
  final String value, label, sub;
  final IconData icon;
  final Color color;
  const _Stat(this.value, this.label, this.icon, this.color, this.sub);
}

class _Action {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _Action(this.icon, this.title, this.subtitle, this.color);
}

class _Event {
  final String time, title;
  final IconData icon;
  final Color color;
  const _Event(this.time, this.title, this.icon, this.color);
}

// ─────────────────────────────────────────────
// SIDEBAR NAV TILE
// ─────────────────────────────────────────────
class _SideNavTile extends StatefulWidget {
  final _SideItem item;
  const _SideNavTile({required this.item});
  @override
  State<_SideNavTile> createState() => _SideNavTileState();
}

class _SideNavTileState extends State<_SideNavTile> {
  bool _hovered = false;
  static const _roseMid = Color(0xFFD4899A);
  static const _rose = Color(0xFFF2C4CE);
  static const _textDim = Color(0xFF8A6070);
  static const _cardHigh = Color(0xFF3A1E28);

  @override
  Widget build(BuildContext context) {
    final sel = widget.item.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sel
              ? _roseMid.withOpacity(0.18)
              : _hovered
              ? Colors.white.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: sel
              ? Border.all(color: _roseMid.withOpacity(0.3))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(widget.item.icon, color: sel ? _rose : _textDim, size: 18),
            const SizedBox(width: 12),
            Text(
              widget.item.label,
              style: TextStyle(
                color: sel ? _rose : _textDim,
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
            if (sel) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _roseMid,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final _Stat stat;
  const _StatCard({required this.stat});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;
  static const _card = Color(0xFF2E1820);
  static const _cardHigh = Color(0xFF3A1E28);
  static const _border = Color(0xFF3D2030);
  static const _text = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    final s = widget.stat;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _hovered ? _cardHigh : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? s.color.withOpacity(0.3) : _border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: s.color.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.icon, color: s.color, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.sub,
                    style: TextStyle(
                      color: s.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              s.value,
              style: TextStyle(
                color: _text,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.label,
              style: const TextStyle(
                color: _textDim,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION TILE
// ─────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final _Action action;
  final bool isHovered;
  final VoidCallback onEnter, onExit;
  const _ActionTile({
    required this.action,
    required this.isHovered,
    required this.onEnter,
    required this.onExit,
  });

  static const _cardHigh = Color(0xFF3A1E28);
  static const _border = Color(0xFF3D2030);
  static const _text = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isHovered ? _cardHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHovered ? action.color.withOpacity(0.3) : _border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: action.color.withOpacity(isHovered ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      color: _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: const TextStyle(
                      color: _textDim,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isHovered
                    ? action.color.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isHovered ? action.color : _textDim,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP ACTION BUTTON
// ─────────────────────────────────────────────
class _TopActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool border;
  const _TopActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.border = false,
  });
  @override
  State<_TopActionBtn> createState() => _TopActionBtnState();
}

class _TopActionBtnState extends State<_TopActionBtn> {
  bool _hovered = false;
  static const _text = Color(0xFFF8EEF1);
  static const _border = Color(0xFF3D2030);

  @override
  Widget build(BuildContext context) {
    final isTeal = !widget.border;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isTeal
              ? (widget.color)
              : _hovered
              ? widget.color
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isTeal ? Colors.transparent : _border),
          boxShadow: isTeal && _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: isTeal ? const Color(0xFF1A0D10) : _text,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: isTeal ? const Color(0xFF1A0D10) : _text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
