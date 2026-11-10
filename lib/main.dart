import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'app/firebase_setup_required_app.dart';
import 'app/app_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const AppProviders(child: UserAdminApp()));
  } catch (error) {
    runApp(FirebaseSetupRequiredApp(message: error.toString()));
  }
}
