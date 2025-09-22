import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/features/auth/presentation/pages/improved_signup_page.dart';
import 'package:netru_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:netru_app/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:netru_app/features/notifications/presentation/pages/notifications_screen.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/cubit/signup_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/admin/presentation/pages/mobile_admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_reports_page.dart';
import '../../features/admin/presentation/pages/admin_report_details_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_notifications_page.dart';
import '../../features/admin/presentation/pages/admin_auth_manager_page.dart';
import '../../features/admin/domain/entities/admin_report_entity.dart';
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import '../../features/admin/presentation/cubit/admin_auth_manager_cubit.dart';
import 'package:netru_app/features/reports/presentation/pages/create_report_page.dart';
import 'package:netru_app/features/heatmap/presentation/pages/crime_heat_map_page.dart';
import 'package:netru_app/features/home/presentation/pages/home_screen.dart';
import 'package:netru_app/features/home/presentation/widgets/custom_bottom_bar.dart';
import 'package:netru_app/features/reports/presentation/pages/report_details_page.dart';
import '../../features/reports/domain/entities/reports_entity.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../routing/routes.dart';

// Onboarding imports
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// Chatbot imports
import '../../features/chatbot/presentation/cubit/chat_cubit.dart';
import '../../features/chatbot/presentation/pages/chat_page.dart';
import '../../features/chatbot/presentation/pages/chat_sessions_page.dart';

// News imports
import '../../features/news/presentation/pages/all_news_page.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return _createRoute(const SplashScreen());
      case Routes.onboardingScreen:
        return _createRoute(const OnboardingPage());
      case Routes.submissionOfaReportPage:
        return _createRoute(const CreateReportPage());
      case Routes.notificationsPage:
        {
          final userId = UserDataHelper().getUserId() ?? '';
          return _createRoute(NotificationsScreen(userId: userId));
        }
      case Routes.loginScreen:
        return _createRoute(
          BlocProvider<LoginCubit>(
            create: (context) => sl<LoginCubit>(),
            child: const LoginPage(),
          ),
        );
      case Routes.signupScreen:
        return _createRoute(
          BlocProvider<SignupCubit>(
            create: (context) => sl<SignupCubit>(),
            child: const ImprovedSignupPage(),
          ),
        );

      // New routes for email verification flow
      case Routes.emailVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(
          EmailVerificationPage(
            email: args['email'],
            password: args['password'],
          ),
        );

      case Routes.completeProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(
          BlocProvider<SignupCubit>(
            create: (context) => sl<SignupCubit>(),
            child: CompleteProfilePage(
              email: args['email'],
              password: args['password'],
            ),
          ),
        );
      case Routes.homeScreen:
        return _createRoute(const HomeScreen());
      case Routes.customBottomBar:
        return _createRoute(const CustomBottomBar());
      case Routes.reportDetailsPage:
        final report = settings.arguments as ReportEntity?;
        return _createRoute(ReportDetailsPage(report: report));
      case Routes.crimeHeatMapPage:
        return _createRoute(const CrimeHeatMapPage());

      // Admin routes
      case Routes.adminDashboard:
        return _createRoute(
          BlocProvider<AdminDashboardCubit>(
            create: (context) => sl<AdminDashboardCubit>(),
            child: const MobileAdminDashboardPage(),
          ),
        );
      case Routes.adminReports:
        return _createRoute(const AdminReportsPage());
      case Routes.adminReportDetails:
        final report = settings.arguments as AdminReportEntity?;
        if (report != null) {
          return _createRoute(AdminReportDetailsPage(report: report));
        }
        return null;
      case Routes.adminUsers:
        return _createRoute(const AdminUsersPage());
      case Routes.adminNotifications:
        return _createRoute(const AdminNotificationsPage());
      case Routes.adminAuthManager:
        return _createRoute(
          BlocProvider<AdminAuthManagerCubit>(
            create: (context) => sl<AdminAuthManagerCubit>(),
            child: const AdminAuthManagerPage(),
          ),
        );

      // // Debug Test route
      // case '/debug-test':
      //   return _createRoute(const DebugTestPage());

      // Chatbot routes
      case Routes.chatPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          BlocProvider<ChatCubit>(
            create: (context) => sl<ChatCubit>(),
            child: ChatPage(sessionId: args?['sessionId']),
          ),
        );

      case Routes.chatSessions:
        return _createRoute(
          BlocProvider<ChatCubit>(
            create: (context) => sl<ChatCubit>(),
            child: const ChatSessionsPage(),
          ),
        );

      // News routes
      case Routes.allNewsPage:
        return _createRoute(const AllNewsPage());

      default:
        return null;
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
