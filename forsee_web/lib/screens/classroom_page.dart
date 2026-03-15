import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student_model.dart';
import '../services/classroom_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/shared_widgets.dart';

class WebClassroomPage extends StatefulWidget {
  final String classroomId;
  const WebClassroomPage({super.key, this.classroomId = 'default_classroom'});

  @override
  State<WebClassroomPage> createState() => _WebClassroomPageState();
}

class _WebClassroomPageState extends State<WebClassroomPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeIn;
  late AnimationController _slideUp;
  String _searchQuery = '';
  
  final _classroomService = ClassroomService();
  List<StudentModel> _students = [];
  Map<String, dynamic>? _classroomData;
  bool _isLoading = true;

  // Brand palette — consistent with teacher_dashboard & report_page
  static const _bg       = Color(0xFF1A0D10);
  static const _surface  = Color(0xFF22111A);
  static const _card     = Color(0xFF2E1820);
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
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final classroomDoc = await _classroomService.getClassroom(widget.classroomId);
      final classroomData = classroomDoc.data() as Map<String, dynamic>?;
      _classroomData = classroomData;

      List<StudentModel> studentList = [];
      final studentIds = classroomData?['studentIds'] as List?;

      if (studentIds != null && studentIds.isNotEmpty) {
        // Option 1: Link via ID array in classroom doc
        final ids = studentIds.map((e) => e.toString()).toList();
        studentList = await _classroomService.getStudentsByIds(ids);
      } else {
        // Option 2: Link via classroomId field in student docs
        final studentSnap = await _classroomService.getClassroomStudents(widget.classroomId).first;
        studentList = studentSnap.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
      }

      setState(() {
        _students = studentList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching students: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _slideUp.dispose();
    super.dispose();
  }

  List<StudentModel> get _filtered => _searchQuery.isEmpty
      ? _students
      : _students.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.name.split(' ').first ?? 'Teacher';

    return Scaffold(
      backgroundColor: _bg,
      body: LoadingOverlay(
        isLoading: _isLoading || auth.isLoading,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              _buildTopBar(context, userName),
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
                            _buildToolbar(),
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
      ),
    );
  }


  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Logo
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

          // Breadcrumb with back navigation — PRESERVED
          GestureDetector(
            onTap: () => context.go('/teacher'),
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
          Text('${_classroomData?['title'] ?? _classroomData?['name'] ?? "Subject"} · ${_classroomData?['std'] ?? _classroomData?['standard'] ?? "Standard"}', style: GoogleFonts.poppins(
            color: _text, fontSize: 13, fontWeight: FontWeight.w600,
          )),

          const Spacer(),

          // Session pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border),
            ),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('${_classroomData?['semester'] ?? "Semester I"}  ·  2025–26', style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 16),

          // Notification bell
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

          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [_roseMid, Color(0xFF8B2240)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: _rose.withOpacity(0.3), width: 1.5),
            ),
            child: Center(child: Text(userName[0], style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14,
            ))),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CLASSROOM HEADER CARD
  // ─────────────────────────────────────────────
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
            // Subject icon
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

            // Title + chips
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_classroomData?['title'] ?? _classroomData?['name'] ?? 'Classroom', style: GoogleFonts.poppins(
                    color: _text, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.1,
                  )),
                  const SizedBox(height: 10),
                  Row(children: [
                    _PillChip(_classroomData?['semester'] ?? 'Semester I', _teal),
                    const SizedBox(width: 10),
                    _PillChip(_classroomData?['std'] ?? _classroomData?['standard'] ?? 'N/A', _rose),
                    const SizedBox(width: 10),
                    _PillChip('2025–26', _textDim),
                  ]),
                ],
              ),
            ),

            // Stats
            _HeaderStat('${_students.length}', 'Participants', Icons.people_rounded, _teal),
            const SizedBox(width: 16),
            _HeaderStat('87%', 'Avg. Score', Icons.bar_chart_rounded, _green),
            const SizedBox(width: 16),
            _HeaderStat('92%', 'Attendance', Icons.check_circle_outline_rounded, _rose),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOOLBAR
  // ─────────────────────────────────────────────
  Widget _buildToolbar() {
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
        const Spacer(),

        // Search
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

        // Upload Attendance
        _ToolbarBtn(
          label: 'Upload Attendance',
          icon: Icons.upload_rounded,
          color: _rose,
          onTap: () => _showAttendanceOptions(context),
        ),
        const SizedBox(width: 12),
        _ToolbarBtn(label: 'Add Student', icon: Icons.add_rounded, color: _teal, onTap: _showAddStudentDialog),
        const SizedBox(width: 12),
        _ToolbarBtn(label: 'Filter', icon: Icons.tune_rounded, color: _card, onTap: () {}, border: true),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // STUDENT GRID
  // ─────────────────────────────────────────────
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
        onTap: () => context.push('/student/profile/${list[i].name}'),
        onRefresh: _fetchStudents,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UPLOAD MARKS BUTTON
  // ─────────────────────────────────────────────
  Widget _buildUploadMarksButton() {
    return Center(
      child: _ToolbarBtn(
        label: 'Upload Marks',
        icon: Icons.assessment_rounded,
        color: _teal,
        onTap: () {},   // PRESERVED
        wide: true,
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final stdController = TextEditingController(text: _classroomData?['std'] ?? _classroomData?['standard'] ?? '');
    final phoneController = TextEditingController();
    final ageController = TextEditingController(text: '16');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: _border)),
        title: Text('Add New Student', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(stdController, 'Standard', Icons.school),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Phone Number', Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(ageController, 'Age', Icons.calendar_today, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: _textDim))),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _classroomService.addStudent(
                  classroomId: widget.classroomId,
                  name: nameController.text,
                  data: {
                    'standard': stdController.text,
                    'phone': phoneController.text,
                    'age': int.tryParse(ageController.text) ?? 16,
                    'G1': 0, 'G2': 0, 'absences': 0,
                    'failures': 0, 'studytime': 2, 'health': 5,
                  },
                );
                _fetchStudents();
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Add Student', style: GoogleFonts.poppins(color: _bg, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A6070), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF8A6070), size: 18),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFF8A6070).withOpacity(0.3))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7ECECA))),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ATTENANCE UPLOAD OPTIONS
  // ─────────────────────────────────────────────
  void _showAttendanceOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _border)),
        title: Text('Upload Attendance', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionCard(
              context,
              'CSV Upload',
              'Upload a .csv file with attendance data',
              Icons.description_rounded,
              _rose,
              () {
                Navigator.pop(ctx);
                _pickCSVFile();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              'Manual Entry',
              'Mark attendance for students manually',
              Icons.edit_note_rounded,
              _teal,
              () {
                Navigator.pop(ctx);
                _showManualAttendanceDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: _textDim)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCSVFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final platformFile = result.files.first;
        String csvString = "";
        
        if (kIsWeb) {
          csvString = utf8.decode(platformFile.bytes!);
        } else {
          // Add non-web support if needed, e.g., result.files.first.path
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing ${platformFile.name}...')),
          );
        }

        final importedCount = await ClassroomService().importStudentsFromCsv(
          classroomId: widget.classroomId,
          csvContent: csvString,
        );
        
        if (mounted) {
          _fetchStudents(); // Refresh UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully imported $importedCount students and updated risk levels.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing CSV: $e')),
        );
      }
    }
  }

  void _showManualAttendanceDialog() {
    // track attendance state locally in dialog
    Map<String, bool> attendance = {
      for (var s in _filtered) s.id: true // Default all to present
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _border)),
            title: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: _teal, size: 28),
                const SizedBox(width: 12),
                Text('Manual Attendance', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('Toggle checkboxes for students who are PRESENT today.', 
                      style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (c, i) {
                        final student = _filtered[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: _bg.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CheckboxListTile(
                            secondary: CircleAvatar(
                              backgroundColor: _textDim.withOpacity(0.2),
                              child: Text(student.name[0], style: TextStyle(color: _teal, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(student.name, style: GoogleFonts.poppins(color: _text, fontSize: 14)),
                            subtitle: Text('Current Absences: ${student.absences}', style: GoogleFonts.poppins(color: _textDim, fontSize: 11)),
                            value: attendance[student.id],
                            activeColor: _teal,
                            checkColor: _bg,
                            onChanged: (val) {
                              setDialogState(() {
                                attendance[student.id] = val ?? false;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: _textDim))),
              ElevatedButton(
                onPressed: () async {
                  // Show loading or just process
                  Navigator.pop(ctx);
                  
                  int updatedCount = 0;
                  for (var student in _filtered) {
                    bool isPresent = attendance[student.id] ?? true;
                    if (!isPresent) {
                      // Only increment absences if marked absent
                      await ClassroomService().updateStudentAttendance(student.id, student.absences + 1);
                      updatedCount++;
                    }
                  }
                  
                  if (mounted) {
                    _fetchStudents();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Attendance updated for $updatedCount students. Risk factors recalculated.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _teal),
                child: Text('Submit', style: GoogleFonts.poppins(color: _bg, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showScannerPlaceholder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _border)),
        title: Text('Scanner', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _teal.withOpacity(0.5), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: _teal, size: 60),
                  const SizedBox(height: 16),
                  Text('Accessing Camera...', style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Position the QR code within the frame', style: GoogleFonts.poppins(color: _text, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: GoogleFonts.poppins(color: _textDim))),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _h ? widget.color.withOpacity(0.12) : widget.color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _h ? widget.color.withOpacity(0.4) : widget.color.withOpacity(0.1), width: 1.2),
          ),
          child: Icon(widget.icon, color: _h ? widget.color : widget.color.withOpacity(0.6), size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
// Student Card and related widgets updated to use StudentModel

// ─────────────────────────────────────────────
// STUDENT CARD
// ─────────────────────────────────────────────
class _StudentCard extends StatefulWidget {
  final StudentModel student;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  const _StudentCard({required this.student, required this.onTap, required this.onRefresh});

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
  static const _red      = Color(0xFFE07070);
  static const _amber    = Color(0xFFFFB74D);
  static const _green    = Color(0xFF81C784);
  static const _teal     = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    Color statusColor;
    String statusLabel;
    
    switch (s.riskLevel) {
      case RiskLevel.high:
        statusColor = _red; statusLabel = 'High Risk'; break;
      case RiskLevel.medium:
        statusColor = _amber; statusLabel = 'Medium Risk'; break;
      case RiskLevel.low:
        statusColor = _green; statusLabel = 'Low Risk'; break;
      default:
        statusColor = _teal; statusLabel = 'Stable';
    }

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
            color: _hovered ? statusColor.withOpacity(0.35) : _border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6)),
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
                color: statusColor.withOpacity(0.12),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
              ),
              child: Center(child: Text(
                s.name.isNotEmpty ? s.name.substring(0, 1) : '?',
                style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.w800, fontSize: 18),
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
                  Text('ID: ${s.id.substring(0, 6)}', style: GoogleFonts.poppins(color: _textDim, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.22)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(statusLabel, style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 14),
            _ActionIcon(
              icon: Icons.calendar_today_rounded, 
              color: _roseMid, 
              label: 'Attendance',
              onTap: () => _showAttendanceDialog(context),
            ),
            const SizedBox(width: 8),
            _ActionIcon(
              icon: Icons.edit_note_rounded, 
              color: _teal, 
              label: 'Marks',
              onTap: () => _showMarksDialog(context),
            ),
            const SizedBox(width: 14),
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

  void _showAttendanceDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.student.absences.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF22111A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF3D2030))),
        title: Text('Update Attendance', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Total Absences',
            labelStyle: const TextStyle(color: _textDim),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _textDim.withOpacity(0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _roseMid)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: _textDim))),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(controller.text) ?? 0;
              await ClassroomService().updateStudentAttendance(widget.student.id, val);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                widget.onRefresh(); // Trigger refresh
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance updated successfully!')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _roseMid),
            child: Text('Update', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMarksDialog(BuildContext context) {
    final g1 = TextEditingController(text: widget.student.g1.toString());
    final g2 = TextEditingController(text: widget.student.g2.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF22111A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF3D2030))),
        title: Text('Update Marks (G1 & G2)', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: g1,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'G1 Marks',
                labelStyle: const TextStyle(color: _textDim),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _textDim.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: g2,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'G2 Marks',
                labelStyle: const TextStyle(color: _textDim),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _textDim.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: _textDim))),
          ElevatedButton(
            onPressed: () async {
              final m1 = int.tryParse(g1.text) ?? 0;
              final m2 = int.tryParse(g2.text) ?? 0;
              await ClassroomService().updateStudentMarks(widget.student.id, m1, m2);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                widget.onRefresh(); // Trigger refresh
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks updated successfully!')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _teal),
            child: Text('Update', style: GoogleFonts.poppins(color: Color(0xFF1A0D10), fontWeight: FontWeight.bold)),
          ),
        ],
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