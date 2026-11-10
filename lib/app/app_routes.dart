import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/users/domain/models/admin_user.dart';
import '../features/users/presentation/screens/admin_home_screen.dart';
import '../features/users/presentation/screens/user_detail_screen.dart';
import '../features/users/presentation/screens/user_form_screen.dart';
import '../features/users/presentation/screens/user_list_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String users = '/users';
  static const String userDetail = '/users/detail';
  static const String userForm = '/users/form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      home => MaterialPageRoute<void>(
        builder: (_) => const AdminHomeScreen(),
        settings: settings,
      ),
      users => MaterialPageRoute<void>(
        builder: (_) => const UserListScreen(),
        settings: settings,
      ),
      userDetail => MaterialPageRoute<void>(
        builder: (_) => UserDetailScreen(email: settings.arguments! as String),
        settings: settings,
      ),
      userForm => MaterialPageRoute<bool>(
        builder: (_) => UserFormScreen(user: settings.arguments as AdminUser?),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const _UnknownRouteScreen(),
        settings: settings,
      ),
    };
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pageNotFound)),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (_) => false,
          ),
          child: const Text(AppStrings.backToHome),
        ),
      ),
    );
  }
}
