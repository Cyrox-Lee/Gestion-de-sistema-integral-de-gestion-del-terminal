import 'package:flutter/material.dart';
import 'package:login_app/presentation/screens/auth/login_screen.dart';
import 'package:login_app/presentation/screens/auth/register_screen.dart';
import 'package:login_app/presentation/screens/visitor/visitor_dashboard_screen.dart';
import 'package:login_app/presentation/screens/visitor/routes_screen.dart';
import 'package:login_app/presentation/screens/visitor/routes_viewer_screen.dart';
import 'package:login_app/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:login_app/presentation/screens/admin/routes_management_screen.dart';
import 'package:login_app/presentation/screens/admin/buses_management_screen.dart';
import 'package:login_app/presentation/screens/admin/drivers_management_screen.dart';
import 'package:login_app/presentation/screens/admin/schedules_management_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String visitor = '/visitor';
  static const String visitorDashboard = '/visitor-dashboard';
  static const String routes = '/routes';
  static const String routesViewer = '/routes-viewer';
  static const String adminDashboard = '/admin-dashboard';
  static const String routesManagement = '/routes-management';
  static const String busesManagement = '/buses-management';
  static const String driversManagement = '/drivers-management';
  static const String schedulesManagement = '/schedules-management';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case visitor:
        return MaterialPageRoute(builder: (_) => const RoutesViewerScreen());
      case visitorDashboard:
        return MaterialPageRoute(builder: (_) => const VisitorDashboardScreen());
      case routes:
        return MaterialPageRoute(builder: (_) => const RoutesScreen());
      case routesViewer:
        return MaterialPageRoute(builder: (_) => const RoutesViewerScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case routesManagement:
        return MaterialPageRoute(builder: (_) => const RoutesManagementScreen());
      case busesManagement:
        return MaterialPageRoute(builder: (_) => const BusesManagementScreen());
      case driversManagement:
        return MaterialPageRoute(builder: (_) => const DriversManagementScreen());
      case schedulesManagement:
        return MaterialPageRoute(builder: (_) => const SchedulesManagementScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}