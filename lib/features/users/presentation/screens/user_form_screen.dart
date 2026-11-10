import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../application/user_controller.dart';
import '../../domain/models/admin_user.dart';
import '../widgets/user_avatar.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({this.user, super.key});

  final AdminUser? user;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late String _imageValue;
  bool _obscurePassword = true;
  bool _isPickingImage = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email);
    _passwordController = TextEditingController(text: widget.user?.matkhau);
    _nameController = TextEditingController(text: widget.user?.hoten);
    _imageValue = widget.user?.hinhanh ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editUser : AppStrings.addUser),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      child: UserAvatar(
                        name: _nameController.text,
                        imageValue: _imageValue,
                        radius: 54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSizes.spaceSm,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('pick-user-image-button'),
                          onPressed: _isPickingImage || controller.isSaving
                              ? null
                              : _pickImage,
                          icon: _isPickingImage
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Chọn hình ảnh'),
                        ),
                        if (_imageValue.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => setState(() => _imageValue = ''),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Bỏ ảnh'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceLg),
                    TextFormField(
                      key: const Key('user-email-field'),
                      controller: _emailController,
                      enabled: !controller.isSaving,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    TextFormField(
                      key: const Key('user-password-field'),
                      controller: _passwordController,
                      enabled: !controller.isSaving,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final error = Validators.required(
                          value,
                          fieldName: 'Mật khẩu',
                        );
                        if (error != null) return error;
                        return value!.length < 6
                            ? 'Mật khẩu phải có ít nhất 6 ký tự'
                            : null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    TextFormField(
                      key: const Key('user-name-field'),
                      controller: _nameController,
                      enabled: !controller.isSaving,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Họ tên',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) =>
                          Validators.required(value, fieldName: 'Họ tên'),
                    ),
                    if (controller.errorMessage != null) ...[
                      const SizedBox(height: AppSizes.spaceMd),
                      Text(
                        controller.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.spaceLg),
                    FilledButton.icon(
                      key: const Key('save-user-button'),
                      onPressed: controller.isSaving ? null : _save,
                      icon: controller.isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        controller.isSaving ? 'Đang lưu...' : 'Lưu người dùng',
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
  }

  String? _validateEmail(String? value) {
    final error = Validators.required(value, fieldName: 'Email');
    if (error != null) return error;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    return valid ? null : 'Email không đúng định dạng';
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 900 * 1024) {
        throw const FormatException(
          'Ảnh sau khi nén vẫn lớn hơn 900 KB. Hãy chọn ảnh nhỏ hơn.',
        );
      }
      final extension = file.name.toLowerCase().split('.').last;
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      if (mounted) {
        setState(
          () => _imageValue = 'data:$mimeType;base64,${base64Encode(bytes)}',
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn hình ảnh: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = AdminUser(
      email: _emailController.text.trim(),
      matkhau: _passwordController.text,
      hoten: _nameController.text.trim(),
      hinhanh: _imageValue,
    );
    final controller = context.read<UserController>();
    final success = _isEditing
        ? await controller.updateUser(
            originalEmail: widget.user!.email,
            user: user,
          )
        : await controller.createUser(user);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isEditing
                    ? 'Cập nhật người dùng thành công.'
                    : 'Thêm người dùng thành công.')
              : controller.errorMessage ?? 'Không thể lưu người dùng.',
        ),
      ),
    );
    if (success) Navigator.pop(context, user.email);
  }
}
