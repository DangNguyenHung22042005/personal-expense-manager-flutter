import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../transactions/presentation/screens/home_screen.dart';
import '../../application/auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthController>().isAuthenticated;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isAuthenticated
          ? const HomeScreen(key: ValueKey('home-screen'))
          : const LoginScreen(key: ValueKey('login-screen')),
    );
  }
}
