import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../application/user_controller.dart';
import '../../domain/models/admin_user.dart';
import '../widgets/user_avatar.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({required this.email, super.key});

  final String email;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _showPassword = false;
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    final user = controller.findByEmail(_email);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.userDetail)),
        body: const Center(child: Text('Người dùng không còn tồn tại.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.userDetail),
        actions: [
          IconButton(
            key: const Key('edit-user-button'),
            tooltip: AppStrings.editUser,
            onPressed: () => _edit(context, user),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const Key('delete-user-button'),
            tooltip: AppStrings.deleteUser,
            onPressed: controller.isSaving
                ? null
                : () => _delete(context, user.email),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                UserAvatar(
                  name: user.hoten,
                  imageValue: user.hinhanh,
                  radius: 58,
                ),
                const SizedBox(height: AppSizes.spaceMd),
                Text(
                  user.hoten,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSizes.spaceLg),
                Card(
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded),
                        title: const Text('Mật khẩu'),
                        subtitle: SelectableText(
                          _showPassword ? user.matkhau : '••••••••',
                        ),
                        trailing: IconButton(
                          key: const Key('show-user-password-button'),
                          tooltip: _showPassword
                              ? 'Ẩn mật khẩu'
                              : 'Hiện mật khẩu',
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Họ tên',
                        value: user.hoten,
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.image_outlined,
                        label: 'Hình ảnh',
                        value: user.hinhanh.isEmpty
                            ? 'Chưa có hình ảnh'
                            : user.hinhanh.startsWith('data:')
                            ? 'Ảnh đã chọn từ thiết bị'
                            : user.hinhanh,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, AdminUser user) async {
    final updatedEmail = await Navigator.pushNamed<String>(
      context,
      AppRoutes.userForm,
      arguments: user,
    );
    if (updatedEmail != null && mounted) {
      setState(() => _email = updatedEmail);
    }
  }

  Future<void> _delete(BuildContext context, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteUser),
        content: const Text(
          'Dữ liệu người dùng sẽ bị xóa. Bạn có chắc muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-user-button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final controller = context.read<UserController>();
    final success = await controller.deleteUser(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã xóa người dùng.'
              : controller.errorMessage ?? 'Xóa thất bại.',
        ),
      ),
    );
    if (success) Navigator.pop(context);
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: SelectableText(value),
  );
}
