import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Palette
    const _bg = Color(0xFF1A0D10);
    const _surface = Color(0xFF22111A);
    const _card = Color(0xFF2E1820);
    const _text = Color(0xFFF8EEF1);
    const _textDim = Color(0xFF8A6070);
    const _teal = Color(0xFF7ECECA);
    const _rose = Color(0xFFF2C4CE);
    const _roseMid = Color(0xFFD4899A);

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
          'Teacher Profile',
          style: GoogleFonts.poppins(color: _text, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _textDim.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(
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
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.poppins(color: _text, fontSize: 32, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              user.designation ?? 'Designation',
                              style: GoogleFonts.poppins(color: _teal, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.email,
                              style: GoogleFonts.poppins(color: _textDim, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.push('/teacher/profile/edit'),
                            icon: const Icon(Icons.edit_outlined, size: 18, color: _bg),
                            label: Text('Edit Profile', style: GoogleFonts.poppins(color: _bg, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => auth.logout(),
                            icon: const Icon(Icons.logout_rounded, size: 18, color: _roseMid),
                            label: Text('Logout', style: GoogleFonts.poppins(color: _roseMid, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _roseMid),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats 
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _textDim.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statistics', style: GoogleFonts.poppins(color: _text, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 20),
                            _buildStatRow('Active Classes', '7', _teal),
                            _buildStatRow('Total Students', '186', _roseMid),
                            _buildStatRow('Avg Performance', '84%', _teal),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Quick Actions
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _textDim.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Actions', style: GoogleFonts.poppins(color: _text, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildActionButton('Attendance', Icons.calendar_today_rounded),
                                _buildActionButton('Results', Icons.assessment_outlined),
                                _buildActionButton('Schedule', Icons.video_call_outlined),
                                _buildActionButton('Reports', Icons.assignment_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: const Color(0xFF8A6070), fontSize: 14)),
          Text(value, style: GoogleFonts.poppins(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8A6070).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7ECECA), size: 28),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(color: const Color(0xFFF8EEF1), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
