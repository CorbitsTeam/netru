import 'package:flutter/material.dart';
import 'package:netru_app/features/auth/presentation/pages/login_page.dart';
import 'package:netru_app/features/auth/presentation/pages/signup_page.dart';
import 'package:netru_app/features/heatmap/presentation/pages/crime_heat_map_page.dart';
import 'package:netru_app/features/home/presentation/pages/home_screen.dart';
import 'package:netru_app/features/home/presentation/widgets/custom_bottom_bar.dart';
import 'package:netru_app/features/reports/presentation/pages/report_details_page.dart';
import 'package:netru_app/features/demo/presentation/screens/permission_demo_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../routing/routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return _createRoute(const SplashScreen());
      case Routes.loginScreen:
        return _createRoute(const LoginPage());
      case Routes.signupScreen:
        return _createRoute(const SignUpPage());
      case Routes.homeScreen:
        return _createRoute(const HomeScreen());
      case Routes.customBottomBar:
        return _createRoute(const CustomBottomBar());
      case Routes.reportDetailsPage:
        return _createRoute(const ReportDetailsPage());
      case Routes.crimeHeatMapPage:
        return _createRoute(const CrimeHeatMapPage());
      case Routes.permissionDemo:
        return _createRoute(const PermissionDemoScreen());
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
