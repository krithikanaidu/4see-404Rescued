import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_pfp_page.dart';
import 'teacher_dashboard.dart';
import 'add_classroom.dart';

void main() {
  runApp(const ForseeWebApp());
}

class ForseeWebApp extends StatelessWidget {
  const ForseeWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebClassroomPage(),
    );
  }
}

class WebClassroomPage extends StatefulWidget {
  const WebClassroomPage({super.key});

  @override
  State<WebClassroomPage> createState() => _WebClassroomPageState();
}

class _WebClassroomPageState extends State<WebClassroomPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeIn;
  late AnimationController _slideUp;
  String _searchQuery = '';

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

  final List<_Student> _students = const [
    _Student('Dhruv Rathee',    'Roll 01', _red,   'Needs Attention'),
    _Student('Sourav Joshi',    'Roll 02', _red,   'Needs Attention'),
    _Student('Dhinchak Pooja',  'Roll 03', _amber, 'Average'),
    _Student('Nishchay Malhan', 'Roll 04', _green, 'Excellent'),
  ];

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

  List<_Student> get _filtered => _searchQuery.isEmpty
      ? _students
      : _students.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 36, 40, 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClassroomHeader(),
                          const SizedBox(height: 32),
                          _buildToolbar(context),
                          const SizedBox(height: 28),
                          _buildStudentGrid(context),
                          const SizedBox(height: 36),
                          _buildUploadMarksButton(),
                          const SizedBox(height: 48),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900),
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
              color: _teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withOpacity(0.3)),
            ),
            child: Text('Classroom', style: GoogleFonts.poppins(
              color: _teal, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
            )),
          ),
          const SizedBox(width: 32),
          // Back nav — PRESERVED
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const TeacherDashboard(),
                  transitionDuration: const Duration(milliseconds: 350),
                  transitionsBuilder: (_, anim, __, child) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero)
                          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: _textDim, size: 13),
                const SizedBox(width: 6),
                Text('Dashboard', style: GoogleFonts.poppins(color: _textDim, fontSize: 13)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Icon(Icons.chevron_right_rounded, color: _textDim, size: 16),
          ),
          Text('Science · STD 5th', style: GoogleFonts.poppins(
            color: _text, fontSize: 13, fontWeight: FontWeight.w600,
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border),
            ),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('Semester II  ·  2025–26', style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 16),
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

  Widget _buildClassroomHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(CurvedAnimation(parent: _slideUp, curve: Curves.easeOutCubic)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_teal.withOpacity(0.16), _card, _card],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _teal.withOpacity(0.22), width: 1.5),
          boxShadow: [
            BoxShadow(color: _teal.withOpacity(0.07), blurRadius: 28, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _teal.withOpacity(0.28)),
              ),
              child: const Icon(Icons.science_rounded, color: _teal, size: 34),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Science', style: GoogleFonts.poppins(
                    color: _text, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.1,
                  )),
                  const SizedBox(height: 10),
                  Row(children: [
                    _PillChip('Semester II', _teal),
                    const SizedBox(width: 10),
                    _PillChip('STD 5th', _rose),
                    const SizedBox(width: 10),
                    _PillChip('2025–26', _textDim),
                  ]),
                ],
              ),
            ),
            _HeaderStat('24', 'Participants', Icons.people_rounded, _teal),
            const SizedBox(width: 16),
            _HeaderStat('87%', 'Avg. Score', Icons.bar_chart_rounded, _green),
            const SizedBox(width: 16),
            _HeaderStat('92%', 'Attendance', Icons.check_circle_outline_rounded, _rose),
          ],
        ),
      ),
    );
  }

  // ── TOOLBAR with + Add Student button ──────────────────────
  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        Text('Students', style: GoogleFonts.poppins(
          color: _text, fontSize: 18, fontWeight: FontWeight.w800,
        )),
        Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _teal.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${_filtered.length}', style: GoogleFonts.poppins(
            color: _teal, fontSize: 12, fontWeight: FontWeight.w700,
          )),
        ),
        const SizedBox(width: 14),

        // ── + ADD STUDENT BUTTON → add_classroom.dart ──
        _AddStudentBtn(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AddClassroomPage(),
              transitionDuration: const Duration(milliseconds: 350),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        // ───────────────────────────────────────────────

        const Spacer(),
        Container(
          width: 250, height: 42,
          decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.poppins(color: _text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search student...',
              hintStyle: GoogleFonts.poppins(color: _textDim, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: _textDim, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _ToolbarBtn(label: 'Upload Attendance', icon: Icons.upload_rounded, color: _rose, onTap: () {}),
        const SizedBox(width: 12),
        _ToolbarBtn(label: 'Filter', icon: Icons.tune_rounded, color: _card, onTap: () {}, border: true),
      ],
    );
  }

  Widget _buildStudentGrid(BuildContext context) {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('No students found', style: GoogleFonts.poppins(color: _textDim, fontSize: 15)),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 3.8,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _StudentCard(
        student: list[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentPfpPage(studentName: list[i].name)),
        ),
      ),
    );
  }

  Widget _buildUploadMarksButton() {
    return Center(
      child: _ToolbarBtn(
        label: 'Upload Marks',
        icon: Icons.assessment_rounded,
        color: _teal,
        onTap: () {},
        wide: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _Student {
  final String name, roll, statusLabel;
  final Color statusColor;
  const _Student(this.name, this.roll, this.statusColor, this.statusLabel);
}

// ─────────────────────────────────────────────
// + ADD STUDENT BUTTON
// ─────────────────────────────────────────────
class _AddStudentBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _AddStudentBtn({required this.onTap});

  @override
  State<_AddStudentBtn> createState() => _AddStudentBtnState();
}

class _AddStudentBtnState extends State<_AddStudentBtn> {
  bool _hovered = false;
  static const _teal = Color(0xFF7ECECA);
  static const _bg   = Color(0xFF1A0D10);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? _teal : _teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? _teal : _teal.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle plus icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _hovered ? _bg.withOpacity(0.15) : _teal.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: _hovered ? _bg : _teal, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'Add Student',
                style: TextStyle(
                  color: _hovered ? _bg : _teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STUDENT CARD
// ─────────────────────────────────────────────
class _StudentCard extends StatefulWidget {
  final _Student student;
  final VoidCallback onTap;
  const _StudentCard({required this.student, required this.onTap});

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
  bool _hovered = false;

  static const _card     = Color(0xFF2E1820);
  static const _cardHigh = Color(0xFF3A1E28);
  static const _border   = Color(0xFF3D2030);
  static const _text     = Color(0xFFF8EEF1);
  static const _textDim  = Color(0xFF8A6070);
  static const _roseMid  = Color(0xFFD4899A);

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: _hovered ? _cardHigh : _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? s.statusColor.withOpacity(0.35) : _border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(color: s.statusColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6)),
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 3)),
                ]
              : [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.statusColor.withOpacity(0.12),
                border: Border.all(color: s.statusColor.withOpacity(0.3), width: 1.5),
              ),
              child: Center(child: Text(
                s.name.substring(0, 1),
                style: GoogleFonts.poppins(color: s.statusColor, fontWeight: FontWeight.w800, fontSize: 18),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.name, style: GoogleFonts.poppins(color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(s.roll, style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: s.statusColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: s.statusColor.withOpacity(0.22)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: s.statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(s.statusLabel, style: GoogleFonts.poppins(
                  color: s.statusColor, fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ]),
            ),
            const SizedBox(width: 14),
            // Arrow — NAVIGATION PRESERVED
            GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _hovered ? _roseMid.withOpacity(0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _hovered ? _roseMid.withOpacity(0.4) : _border),
                ),
                child: Icon(Icons.arrow_forward_rounded, color: _hovered ? _roseMid : _textDim, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER STAT
// ─────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _HeaderStat(this.value, this.label, this.icon, this.color);

  static const _card    = Color(0xFF2E1820);
  static const _border  = Color(0xFF3D2030);
  static const _text    = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.poppins(color: _text, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
        ]),
      ]),
    );
  }
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
      child: Text(label, style: GoogleFonts.poppins(
        color: color, fontSize: 12, fontWeight: FontWeight.w600,
      )),
    );
  }
}

// ─────────────────────────────────────────────
// TOOLBAR BUTTON
// ─────────────────────────────────────────────
class _ToolbarBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool border;
  final bool wide;
  const _ToolbarBtn({
    required this.label, required this.icon, required this.color,
    required this.onTap, this.border = false, this.wide = false,
  });

  @override
  State<_ToolbarBtn> createState() => _ToolbarBtnState();
}

class _ToolbarBtnState extends State<_ToolbarBtn> {
  bool _hovered = false;
  static const _border = Color(0xFF3D2030);
  static const _text   = Color(0xFFF8EEF1);

  @override
  Widget build(BuildContext context) {
    final isFlat = !widget.border;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: widget.wide ? 44 : 18, vertical: 12),
          decoration: BoxDecoration(
            color: isFlat ? widget.color : (_hovered ? widget.color.withOpacity(0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isFlat ? Colors.transparent : _border),
            boxShadow: isFlat && _hovered
                ? [BoxShadow(color: widget.color.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: isFlat ? const Color(0xFF1A0D10) : _text, size: 16),
            const SizedBox(width: 8),
            Text(widget.label, style: GoogleFonts.poppins(
              color: isFlat ? const Color(0xFF1A0D10) : _text,
              fontSize: 13, fontWeight: FontWeight.w700,
            )),
          ]),
        ),
      ),
    );
  }
}