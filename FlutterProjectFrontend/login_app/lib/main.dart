import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_app/core/constants/app_strings.dart';
import 'package:login_app/core/routes/app_routes.dart';
import 'package:login_app/core/theme/app_theme.dart';
import 'package:login_app/presentation/providers/auth_provider.dart';
import 'package:login_app/presentation/providers/routes_provider.dart';
import 'package:login_app/presentation/providers/booking_provider.dart';

void main() {
  runApp(const TerminalApp());
}

class TerminalApp extends StatelessWidget {
  const TerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveedor de autenticación (se crea primero)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Proveedores de negocio
        ChangeNotifierProvider(create: (_) => RoutesProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}