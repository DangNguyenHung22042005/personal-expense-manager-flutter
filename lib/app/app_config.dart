import '../core/constants/app_strings.dart';

class AppConfig {
  const AppConfig({
    this.appName = AppStrings.appName,
    this.showDebugBanner = false,
  });

  final String appName;
  final bool showDebugBanner;
}
