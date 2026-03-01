import 'package:flutter/material.dart';

void main() {
  runApp(const AddClassroomPage());
}

class AddClassroomPage extends StatelessWidget {
  const AddClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Classroom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          background: const Color(0xFF1A0A12),
          surface: const Color(0xFF2D1221),
          primary: const Color(0xFFC4547A),
        ),
        useMaterial3: true,
      ),
      home: const NewClassroomPage(),
    );
  }
}

class NewClassroomPage extends StatefulWidget {
  const NewClassroomPage({super.key});

  @override
  State<NewClassroomPage> createState() => _NewClassroomPageState();
}

class _NewClassroomPageState extends State<NewClassroomPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();

  String _selectedStandard = 'STD 9th';
  String _selectedSemester = 'Semester I';
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _standards = [
    'STD 1st', 'STD 2nd', 'STD 3rd', 'STD 4th',
    'STD 5th', 'STD 6th', 'STD 7th', 'STD 8th',
    'STD 9th', 'STD 10th', 'STD 11th', 'STD 12th',
  ];

  final List<String> _semesters = ['Semester I', 'Semester II'];

  // Colors
  static const Color bgColor = Color(0xFF1A0A12);
  static const Color surfaceColor = Color(0xFF2D1221);
  static const Color surface2Color = Color(0xFF3D1A2E);
  static const Color accentColor = Color(0xFFC4547A);
  static const Color accent2Color = Color(0xFFE8859A);
  static const Color textColor = Color(0xFFF5E8EE);
  static const Color mutedColor = Color(0xFF9A6A7E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _createClassroom() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Classroom created successfully!'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background glow top-right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Background glow bottom-left
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5A1437).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: accentColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 14, color: mutedColor),
                                SizedBox(width: 6),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 13,
                                    letterSpacing: 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Header
                        const Text(
                          'New Classroom',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentColor, Colors.transparent],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Set up your class in seconds.',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Class Title field
                        _buildLabel('Class Title'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: 'e.g. Mathematics — Batch A',
                          icon: Icons.article_outlined,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter a class title'
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Subject field
                        _buildLabel('Subject'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _subjectController,
                          hint: 'e.g. Algebra, Physics, History',
                          icon: Icons.menu_book_outlined,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter a subject'
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Standard & Semester row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Standard'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedStandard,
                                    items: _standards,
                                    icon: Icons.school_outlined,
                                    onChanged: (val) => setState(
                                        () => _selectedStandard = val!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Semester'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedSemester,
                                    items: _semesters,
                                    icon: Icons.calendar_today_outlined,
                                    onChanged: (val) => setState(
                                        () => _selectedSemester = val!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Info box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accentColor.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: accentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: 'A '),
                                      TextSpan(
                                        text: 'unique 6-character class code',
                                        style: TextStyle(
                                          color: accent2Color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' will be generated automatically.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Create Classroom button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [accentColor, Color(0xFFA03060)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createClassroom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Create Classroom',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.04,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: mutedColor.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: mutedColor, size: 18),
        filled: true,
        fillColor: surface2Color,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: accentColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface2Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: surface2Color,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: mutedColor,
            size: 20,
          ),
          style: const TextStyle(
            color: textColor,
            fontSize: 14,
            fontFamily: 'sans-serif',
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: mutedColor, size: 16),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}