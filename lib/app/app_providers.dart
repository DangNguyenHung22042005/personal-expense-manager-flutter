import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/users/application/user_controller.dart';
import '../features/users/data/repositories/firebase_user_repository.dart';
import '../features/users/domain/repositories/user_repository.dart';
import 'app_config.dart';

/// Composition root for application dependencies.
///
/// Repositories and controllers will be registered here in the next phases.
class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.child,
    this.authRepository,
    this.userRepository,
    super.key,
  });

  final Widget child;
  final AuthRepository? authRepository;
  final UserRepository? userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: const AppConfig()),
        Provider<AuthRepository>(
          create: (_) => authRepository ?? FirebaseAuthRepository(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(repository: context.read<AuthRepository>()),
        ),
        Provider<UserRepository>(
          create: (_) => userRepository ?? FirebaseUserRepository(),
        ),
        ChangeNotifierProvider<UserController>(
          create: (context) =>
              UserController(repository: context.read<UserRepository>())
                ..loadUsers(),
        ),
      ],
      child: child,
    );
  }
}
