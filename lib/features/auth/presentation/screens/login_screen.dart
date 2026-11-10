import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/demo_account.dart';
import '../../../../core/utils/validators.dart';
import '../../application/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSizes.spaceMd,
                AppSizes.spaceLg,
                AppSizes.spaceMd,
                AppSizes.spaceLg + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSizes.spaceLg * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 38,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.spaceLg),
                            Text(
                              AppStrings.loginTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: AppSizes.spaceSm),
                            Text(
                              AppStrings.loginSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: AppSizes.spaceXl),
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.spaceLg),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      key: const Key('login-email-field'),
                                      controller: _emailController,
                                      enabled: !authController.isLoading,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      textInputAction: TextInputAction.next,
                                      onChanged: (_) =>
                                          authController.clearError(),
                                      onTapOutside: (_) =>
                                          FocusScope.of(context).unfocus(),
                                      decoration: const InputDecoration(
                                        labelText: AppStrings.email,
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      validator: (value) => Validators.required(
                                        value,
                                        fieldName: AppStrings.email,
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.spaceMd),
                                    TextFormField(
                                      key: const Key('login-password-field'),
                                      controller: _passwordController,
                                      enabled: !authController.isLoading,
                                      obscureText: _obscurePassword,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      textInputAction: TextInputAction.done,
                                      onChanged: (_) =>
                                          authController.clearError(),
                                      onFieldSubmitted: (_) => _submit(),
                                      onTapOutside: (_) =>
                                          FocusScope.of(context).unfocus(),
                                      decoration: InputDecoration(
                                        labelText: AppStrings.password,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                        ),
                                        suffixIcon: IconButton(
                                          key: const Key(
                                            'toggle-password-visibility',
                                          ),
                                          tooltip: _obscurePassword
                                              ? 'Hiện mật khẩu'
                                              : 'Ẩn mật khẩu',
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                        ),
                                      ),
                                      validator: (value) => Validators.required(
                                        value,
                                        fieldName: AppStrings.password,
                                      ),
                                    ),
                                    if (authController.errorMessage !=
                                        null) ...[
                                      const SizedBox(height: AppSizes.spaceMd),
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSizes.spaceMd,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.errorContainer,
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusMd,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.error_outline_rounded,
                                              color: colorScheme.error,
                                            ),
                                            const SizedBox(
                                              width: AppSizes.spaceSm,
                                            ),
                                            Expanded(
                                              child: Text(
                                                authController.errorMessage!,
                                                style: TextStyle(
                                                  color: colorScheme
                                                      .onErrorContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: AppSizes.spaceLg),
                                    FilledButton.icon(
                                      key: const Key('login-button'),
                                      onPressed: authController.isLoading
                                          ? null
                                          : _submit,
                                      icon: authController.isLoading
                                          ? const SizedBox.square(
                                              dimension: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.login_rounded),
                                      label: Text(
                                        authController.isLoading
                                            ? 'Đang đăng nhập...'
                                            : AppStrings.signIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.spaceMd),
                            Container(
                              padding: const EdgeInsets.all(AppSizes.spaceMd),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Tài khoản demo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: AppSizes.spaceXs),
                                  const SelectableText(
                                    '${DemoAccount.email} / ${DemoAccount.password}',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSizes.spaceSm),
                                  TextButton.icon(
                                    key: const Key(
                                      'fill-demo-credentials-button',
                                    ),
                                    onPressed: authController.isLoading
                                        ? null
                                        : _fillDemoCredentials,
                                    icon: const Icon(
                                      Icons.auto_fix_high_rounded,
                                    ),
                                    label: const Text('Điền tài khoản demo'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _fillDemoCredentials() {
    _emailController.text = DemoAccount.email;
    _passwordController.text = DemoAccount.password;
    context.read<AuthController>().clearError();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await context.read<AuthController>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
