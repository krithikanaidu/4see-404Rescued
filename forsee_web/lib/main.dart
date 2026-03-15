import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'models/user_model.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

// ── Pages ────────────────────────────────────────────────────────────────────
import 'screens/landing_page.dart';
import 'screens/landing_page2.dart' hide LandingPage; // Hide collision
import 'screens/login_page.dart'; // Contains SignupPage
import 'screens/role_selection_page.dart';
import 'screens/signup_page_student.dart';
import 'screens/signup_page_teacher.dart';
import 'screens/signup_page_admin.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/classroom_page.dart'; // Contains WebClassroomPage
import 'screens/add_classroom.dart'; // Contains NewClassroomPage
import 'screens/student_profile_page.dart';
import 'screens/student_pfp_page.dart';
import 'screens/quiz_start_page.dart';
import 'screens/report_page.dart';
import 'screens/admin_dashboard.dart';
import 'screens/teacher_profile/teacher_profile_page.dart';
import 'screens/teacher_profile/edit_teacher_info_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '4See — Student Dropout Prediction',
            theme: AppTheme.themeData,
            routerConfig: _createRouter(auth),
          );
        },
      ),
    );
  }

  // ── GoRouter Configuration ──────────────────────────────────────────────

  GoRouter _createRouter(AuthController auth) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation.startsWith('/signup/');
        final isPublicRoute = state.matchedLocation == '/' ||
            state.matchedLocation == '/welcome';

        // If loading, don't redirect yet
        if (auth.isLoading) return null;

        // If not logged in and trying to access protected route
        if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
          return '/login';
        }

        // If logged in and trying to access auth routes, redirect to dashboard
        if (isLoggedIn && isAuthRoute) {
          return _dashboardRoute(auth.role);
        }

        return null;
      },
      routes: [
        // ── Public Routes ──────────────────────────────────────────────
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const LandingPage2(),
        ),

        // ── Auth Routes ────────────────────────────────────────────────
        GoRoute(
          path: '/login',
          builder: (context, state) => const SignupPage(), // Correct class name
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const RoleSelectionPage(),
        ),
        GoRoute(
          path: '/signup/student',
          builder: (context, state) => const SignupPageStudent(),
        ),
        GoRoute(
          path: '/signup/teacher',
          builder: (context, state) => const SignupPageTeacher(),
        ),
        GoRoute(
          path: '/signup/admin',
          builder: (context, state) => const SignupPageAdmin(),
        ),

        // ── Teacher Routes ─────────────────────────────────────────────
        GoRoute(
          path: '/teacher',
          builder: (context, state) => const TeacherDashboard(),
        ),
        GoRoute(
          path: '/teacher/classroom/:cid',
          builder: (context, state) {
            final cid = state.pathParameters['cid'] ?? 'default_classroom';
            return WebClassroomPage(classroomId: cid);
          },
        ),
        GoRoute(
          path: '/teacher/add-classroom',
          builder: (context, state) => const NewClassroomPage(), // Correct class name
        ),
        GoRoute(
          path: '/teacher/profile',
          builder: (context, state) => const TeacherProfilePage(),
        ),
        GoRoute(
          path: '/teacher/profile/edit',
          builder: (context, state) => const EditTeacherInfoPage(),
        ),

        // ── Student Routes ─────────────────────────────────────────────
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentProfilePage(),
        ),
        GoRoute(
          path: '/student/profile/:name',
          builder: (context, state) {
            final name = state.pathParameters['name'] ?? 'Student';
            return StudentPfpPage(studentName: name);
          },
        ),
        GoRoute(
          path: '/student/quiz',
          builder: (context, state) => const QuizStartPage(showSidebar: false),
        ),
        GoRoute(
          path: '/student/report',
          builder: (context, state) => const ReportPage(),
        ),

        // ── Admin Routes ───────────────────────────────────────────────
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboard(),
        ),
      ],
    );
  }

  String _dashboardRoute(UserRole? role) {
    switch (role) {
      case UserRole.teacher:
        return '/teacher';
      case UserRole.admin:
        return '/admin';
      case UserRole.student:
        return '/student';
      default:
        return '/';
    }
  }
}
