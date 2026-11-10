import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/user_controller.dart';
import '../widgets/user_card.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: controller.isLoading ? null : controller.loadUsers,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            key: const Key('logout-button'),
            tooltip: AppStrings.signOut,
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _HomeBody(controller: controller),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-user-button'),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.userForm),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(AppStrings.addUser),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi UserAdmin không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-logout-button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().signOut();
    }
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.controller});
  final UserController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.users.isEmpty) {
      return const AppLoading();
    }
    if (controller.errorMessage != null && controller.users.isEmpty) {
      return Center(
        child: AppErrorState(
          message: controller.errorMessage!,
          onRetry: controller.loadUsers,
        ),
      );
    }
    final recentUsers = controller.users.take(5).toList();
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.loadUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spaceLg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primaryContainer,
                          colors.secondaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups_2_rounded,
                          size: 52,
                          color: colors.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppSizes.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng số người dùng',
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '${controller.totalUsers}',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colors.onPrimaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Người dùng gần đây',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.users),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  if (recentUsers.isEmpty)
                    AppEmptyState(
                      title: 'Chưa có người dùng',
                      message: 'Hãy thêm người dùng đầu tiên vào hệ thống.',
                      icon: Icons.person_off_outlined,
                      actionLabel: AppStrings.addUser,
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.userForm),
                    )
                  else
                    for (final user in recentUsers)
                      UserCard(
                        key: Key('user-card-${user.email}'),
                        user: user,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.userDetail,
                          arguments: user.email,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
