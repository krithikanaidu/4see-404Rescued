import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentPfpPage extends StatefulWidget {
  final String studentName;
  const StudentPfpPage({super.key, required this.studentName});

  @override
  State<StudentPfpPage> createState() => _StudentPfpPageState();
}

class _StudentPfpPageState extends State<StudentPfpPage>
    with TickerProviderStateMixin {
  String _selectedReport = 'Semester';
  late AnimationController _fadeIn;
  late AnimationController _slideUp;

  // Brand palette — consistent with entire 4see suite
  static const _bg       = Color(0xFF1A0D10);
  static const _surface  = Color(0xFF22111A);
  static const _card     = Color(0xFF2E1820);
  static const _cardHigh = Color(0xFF3A1E28);
  static const _rose     = Color(0xFFF2C4CE);
  static const _roseMid  = Color(0xFFD4899A);
  static const _teal     = Color(0xFF7ECECA);
  static const _green    = Color(0xFF7BC67E);
  static const _red      = Color(0xFFE07070);
  static const _amber    = Color(0xFFFFB347);
  static const _text     = Color(0xFFF8EEF1);
  static const _textDim  = Color(0xFF8A6070);
  static const _border   = Color(0xFF3D2030);

  @override
  void initState() {
    super.initState();
    _fadeIn  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _slideUp = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
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
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                          .animate(CurvedAnimation(parent: _slideUp, curve: Curves.easeOutCubic)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 28),
                          _buildReportsSection(),
                          const SizedBox(height: 24),
                          _buildRiskCard(),
                          const SizedBox(height: 20),
                          _buildAISuggestions(),
                          const SizedBox(height: 20),
                          _buildSupportResources(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Logo
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900),
              children: const [
                TextSpan(text: '4', style: TextStyle(color: _rose)),
                TextSpan(text: 'see', style: TextStyle(color: _text)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _rose.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _rose.withOpacity(0.3)),
            ),
            child: Text('Student Profile', style: GoogleFonts.poppins(
              color: _rose, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
            )),
          ),
          const SizedBox(width: 28),

          // Breadcrumb with back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: _textDim, size: 13),
                const SizedBox(width: 6),
                Text('Classroom', style: GoogleFonts.poppins(color: _textDim, fontSize: 13)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Icon(Icons.chevron_right_rounded, color: _textDim, size: 16),
          ),
          Text(widget.studentName, style: GoogleFonts.poppins(
            color: _text, fontSize: 13, fontWeight: FontWeight.w600,
          )),

          const Spacer(),

          // Notification + avatar
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
              child: const Icon(Icons.notifications_outlined, color: _textDim, size: 18),
            ),
            Positioned(top: -2, right: -2, child: Container(
              width: 9, height: 9,
              decoration: BoxDecoration(color: _roseMid, shape: BoxShape.circle, border: Border.all(color: _surface, width: 1.5)),
            )),
          ]),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [_roseMid, Color(0xFF8B2240)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: _rose.withOpacity(0.3), width: 1.5),
            ),
            child: Center(child: Text('R', style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14,
            ))),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PROFILE HEADER
  // ─────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_roseMid.withOpacity(0.14), _card, _card],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _roseMid.withOpacity(0.22), width: 1.5),
        boxShadow: [
          BoxShadow(color: _roseMid.withOpacity(0.07), blurRadius: 24, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_roseMid, Color(0xFF8B2240)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: _rose.withOpacity(0.4), width: 2.5),
              boxShadow: [BoxShadow(color: _roseMid.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                widget.studentName.substring(0, 1),
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 28),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.studentName, style: GoogleFonts.poppins(
                  color: _text, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5,
                )),
                const SizedBox(height: 4),
                Text('#01245', style: GoogleFonts.poppins(color: _textDim, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  _PillChip('Std 5th', _rose),
                  const SizedBox(width: 10),
                  _PillChip('Section B', _teal),
                  const SizedBox(width: 10),
                  _PillChip('91+ 9375459378', _textDim),
                ]),
              ],
            ),
          ),

          // Mini stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat('54%', 'Attendance', _red),
              const SizedBox(height: 12),
              _MiniStat('61%', 'Avg Score', _amber),
              const SizedBox(height: 12),
              _MiniStat('Low', 'Focus', _roseMid),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // REPORTS SECTION
  // ─────────────────────────────────────────────
  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reports', style: GoogleFonts.poppins(
              color: _text, fontSize: 18, fontWeight: FontWeight.w800,
            )),
            const Spacer(),
            // Report filter chips
            ...['Semester', 'Weekly', 'Monthly'].map((label) {
              final isSelected = _selectedReport == label;
              return GestureDetector(
                onTap: () => setState(() => _selectedReport = label),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _roseMid : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _roseMid : _border,
                        width: isSelected ? 0 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: _roseMid.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Text(label, style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : _textDim,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    )),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Bar chart mockup for selected period
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Performance · $_selectedReport', style: GoogleFonts.poppins(
                color: _textDim, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
              )),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BarItem('Math',    0.61, _red),
                  _BarItem('Science', 0.74, _amber),
                  _BarItem('English', 0.55, _red),
                  _BarItem('SS',      0.80, _green),
                  _BarItem('Hindi',   0.68, _amber),
                ],
              ),
              const SizedBox(height: 16),
              // Behaviour Incident button — onPressed: () {} PRESERVED
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'Behaviour Incident',
                  icon: Icons.warning_amber_rounded,
                  color: _roseMid,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HIGH RISK CARD
  // ─────────────────────────────────────────────
  Widget _buildRiskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _red.withOpacity(0.35), width: 1.5),
        boxShadow: [BoxShadow(color: _red.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.warning_rounded, color: _red, size: 18),
            ),
            const SizedBox(width: 12),
            Text('HIGH RISK — ATTENTION NEEDED', style: GoogleFonts.poppins(
              color: _red, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5,
            )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _red.withOpacity(0.3)),
              ),
              child: Text('Critical', style: GoogleFonts.poppins(color: _red, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _RiskTile(Icons.calendar_today_rounded, 'Attendance', 'Below 60%', _red)),
              const SizedBox(width: 14),
              Expanded(child: _RiskTile(Icons.trending_down_rounded, 'Math Scores', 'Declined 15%', _amber)),
              const SizedBox(width: 14),
              Expanded(child: _RiskTile(Icons.psychology_outlined, 'Behaviour', 'Low Focus', _roseMid)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI SUGGESTIONS
  // ─────────────────────────────────────────────
  Widget _buildAISuggestions() {
    final suggestions = [
      _Suggestion(Icons.people_alt_rounded,   'Assign Peer Mentor',       'Pair with a high-performing classmate for study sessions', _teal),
      _Suggestion(Icons.school_rounded,        'Recommend Remedial Classes','Enroll in weekend Math & English support program',         _rose),
      _Suggestion(Icons.family_restroom_rounded,'Parent Meeting',           'Schedule a meeting within the next 7 days',                _amber),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: _teal, size: 18),
            ),
            const SizedBox(width: 12),
            Text('AI Suggestions', style: GoogleFonts.poppins(
              color: _text, fontSize: 16, fontWeight: FontWeight.w800,
            )),
          ]),
          const SizedBox(height: 20),
          ...suggestions.map((s) => _SuggestionTile(suggestion: s)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUPPORT & RESOURCES
  // ─────────────────────────────────────────────
  Widget _buildSupportResources() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support & Resources', style: GoogleFonts.poppins(
            color: _text, fontSize: 16, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _ResourceCard(Icons.handshake_outlined, 'NGO Support', 'Connect with local NGO partner', _rose)),
            const SizedBox(width: 14),
            Expanded(child: _ResourceCard(Icons.chat_bubble_outline_rounded, 'Counseling', 'Book a counseling session', _teal)),
            const SizedBox(width: 14),
            Expanded(child: _ResourceCard(Icons.menu_book_rounded, 'Study Aid', 'Access remedial resources', _amber)),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class _Suggestion {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _Suggestion(this.icon, this.title, this.subtitle, this.color);
}

// ─────────────────────────────────────────────
// PILL CHIP
// ─────────────────────────────────────────────
class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PillChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins',
      )),
    );
  }
}

// ─────────────────────────────────────────────
// MINI STAT
// ─────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat(this.value, this.label, this.color);

  static const _textDim = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: TextStyle(
          color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Poppins',
        )),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(label, style: const TextStyle(
            color: _textDim, fontSize: 11, fontFamily: 'Poppins',
          )),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BAR ITEM (chart)
// ─────────────────────────────────────────────
class _BarItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _BarItem(this.label, this.value, this.color);

  static const _textDim = Color(0xFF8A6070);
  static const _text    = Color(0xFFF8EEF1);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${(value * 100).toInt()}%', style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
        )),
        const SizedBox(height: 6),
        Container(
          width: 44,
          height: 100 * value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color, color.withOpacity(0.4)],
            ),
            boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: _textDim, fontSize: 11, fontFamily: 'Poppins')),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// RISK TILE
// ─────────────────────────────────────────────
class _RiskTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color color;
  const _RiskTile(this.icon, this.title, this.value, this.color);

  static const _text = Color(0xFFF8EEF1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUGGESTION TILE
// ─────────────────────────────────────────────
class _SuggestionTile extends StatefulWidget {
  final _Suggestion suggestion;
  const _SuggestionTile({required this.suggestion});

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _hovered = false;
  static const _cardHigh = Color(0xFF3A1E28);
  static const _border   = Color(0xFF3D2030);
  static const _text     = Color(0xFFF8EEF1);
  static const _textDim  = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? _cardHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? s.color.withOpacity(0.3) : _border),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: s.color.withOpacity(_hovered ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(s.icon, color: s.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.title, style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Text(s.subtitle, style: const TextStyle(color: _textDim, fontSize: 12, fontFamily: 'Poppins')),
            ]),
          ),
          Icon(Icons.arrow_forward_rounded, color: _hovered ? s.color : _textDim, size: 16),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RESOURCE CARD
// ─────────────────────────────────────────────
class _ResourceCard extends StatefulWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _ResourceCard(this.icon, this.title, this.subtitle, this.color);

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  bool _hovered = false;
  static const _cardHigh = Color(0xFF3A1E28);
  static const _border   = Color(0xFF3D2030);
  static const _text     = Color(0xFFF8EEF1);
  static const _textDim  = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? _cardHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? widget.color.withOpacity(0.35) : _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(widget.title, style: TextStyle(
              color: _text, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
            )),
            const SizedBox(height: 3),
            Text(widget.subtitle, style: const TextStyle(color: _textDim, fontSize: 11, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.color.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 5))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(widget.label, style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
              )),
            ],
          ),
        ),
      ),
    );
  }
}