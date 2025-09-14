import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/auth/presentation/pages/improved_signup_page.dart';
import 'package:netru_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:netru_app/features/auth/presentation/pages/complete_profile_page.dart';
import '../di/auth_injection.dart' as auth_di;
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/signup_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/page/submission_of_report_page.dart';
import 'package:netru_app/features/heatmap/presentation/pages/crime_heat_map_page.dart';
import 'package:netru_app/features/home/presentation/pages/home_screen.dart';
import 'package:netru_app/features/home/presentation/widgets/custom_bottom_bar.dart';
import 'package:netru_app/features/profile/presentation/page/profile_page.dart';
import 'package:netru_app/features/reports/presentation/pages/report_details_page.dart';
import '../../features/splash/splash_screen.dart';
import '../routing/routes.dart';

// Chatbot imports
import '../../features/chatbot/di/chatbot_di.dart' as chatbot_di;
import '../../features/chatbot/presentation/cubit/chat_cubit.dart';
import '../../features/chatbot/presentation/pages/chat_page.dart';
import '../../features/chatbot/presentation/pages/chat_sessions_page.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return _createRoute(const SplashScreen());
      case Routes.profileScreen:
        return _createRoute(const ProfilePage());
      case Routes.submissionOfaReportPage:
        return _createRoute(const SubmissionOfaReportPage());
      case Routes.loginScreen:
        return _createRoute(
          BlocProvider<AuthCubit>(
            create: (context) => auth_di.sl<AuthCubit>(),
            child: const LoginPage(),
          ),
        );
      case Routes.signupScreen:
        return _createRoute(
          BlocProvider<SignupCubit>(
            create: (context) => auth_di.sl<SignupCubit>(),
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
            create: (context) => auth_di.sl<SignupCubit>(),
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
        return _createRoute(const ReportDetailsPage());
      case Routes.crimeHeatMapPage:
        return _createRoute(const CrimeHeatMapPage());

      // Chatbot routes
      case Routes.chatPage:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          BlocProvider<ChatCubit>(
            create: (context) => chatbot_di.getIt<ChatCubit>(),
            child: ChatPage(sessionId: args?['sessionId']),
          ),
        );

      case Routes.chatSessions:
        return _createRoute(
          BlocProvider<ChatCubit>(
            create: (context) => chatbot_di.getIt<ChatCubit>(),
            child: const ChatSessionsPage(),
          ),
        );

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
