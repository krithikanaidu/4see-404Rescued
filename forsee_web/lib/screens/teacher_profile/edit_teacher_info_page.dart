import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class EditTeacherInfoPage extends StatefulWidget {
  const EditTeacherInfoPage({super.key});

  @override
  State<EditTeacherInfoPage> createState() => _EditTeacherInfoPageState();
}

class _EditTeacherInfoPageState extends State<EditTeacherInfoPage> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _qualificationController;
  late TextEditingController _addressController;

  bool _isSaving = false;

  // Palette
  static const _bg = Color(0xFF1A0D10);
  static const _surface = Color(0xFF22111A);
  static const _card = Color(0xFF2E1820);
  static const _text = Color(0xFFF8EEF1);
  static const _textDim = Color(0xFF8A6070);
  static const _teal = Color(0xFF7ECECA);
  static const _rose = Color(0xFFF2C4CE);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(context, listen: false).currentUser!;
    _nameController = TextEditingController(text: user.name);
    _idController = TextEditingController(text: user.employeeId ?? '');
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _emailController = TextEditingController(text: user.email);
    _designationController = TextEditingController(text: user.designation ?? '');
    _departmentController = TextEditingController(text: user.department ?? '');
    _qualificationController = TextEditingController(text: user.qualification ?? '');
    _addressController = TextEditingController(text: user.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _qualificationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthController>(context, listen: false);

    final success = await auth.updateProfile({
      'name': _nameController.text,
      'employeeId': _idController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text, // Note: Changing email in firestore doesn't change it in Auth
      'designation': _designationController.text,
      'department': _departmentController.text,
      'qualification': _qualificationController.text,
      'address': _addressController.text,
    });

    if (mounted) setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );
      context.go('/teacher/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${auth.error ?? "Unknown error"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Professional Profile',
          style: GoogleFonts.poppins(color: _text, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _textDim.withOpacity(0.2),
                            border: Border.all(color: _teal.withOpacity(0.3), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 50, color: _textDim),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: _teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: _bg, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update your details', style: GoogleFonts.poppins(color: _text, fontSize: 24, fontWeight: FontWeight.w700)),
                        Text('Manage your professional identity on 4See', style: GoogleFonts.poppins(color: _textDim, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Section: Personal Details
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildField('FULL NAME', _nameController, _text, _textDim, _card)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildField('PHONE NUMBER', _phoneController, _text, _textDim, _card)),
                  ],
                ),
                _buildField('EMAIL ADDRESS', _emailController, _text, _textDim, _card, enabled: false),
                _buildField('RESIDENTIAL ADDRESS', _addressController, _text, _textDim, _card),

                const SizedBox(height: 40),

                // Section: Professional Details
                _buildSectionTitle('Professional Details'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildField('EMPLOYEE ID', _idController, _text, _textDim, _card)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildField('DESIGNATION', _designationController, _text, _textDim, _card)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildField('DEPARTMENT', _departmentController, _text, _textDim, _card)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildField('QUALIFICATION', _qualificationController, _text, _textDim, _card)),
                  ],
                ),

                const SizedBox(height: 48),

                Row(
                  children: [
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _textDim.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins(color: _text, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _bg, strokeWidth: 2))
                          : Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(color: _bg, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(color: const Color(0xFF7ECECA), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        const SizedBox(height: 4),
        Container(width: 40, height: 2, color: const Color(0xFF7ECECA).withOpacity(0.3)),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, Color text, Color textDim, Color card, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: textDim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: enabled ? card.withOpacity(0.5) : _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: enabled ? textDim.withOpacity(0.1) : Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: GoogleFonts.poppins(color: enabled ? text : textDim, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
