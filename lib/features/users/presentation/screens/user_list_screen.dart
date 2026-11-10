import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../application/user_controller.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.userList)),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  child: TextField(
                    key: const Key('user-search-field'),
                    controller: _searchController,
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo họ tên hoặc email',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                controller.search('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _ListBody(controller: controller)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.userForm),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({required this.controller});
  final UserController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.users.isEmpty) {
      return const AppLoading();
    }
    final users = controller.filteredUsers;
    if (users.isEmpty) {
      return const AppEmptyState(
        title: 'Không tìm thấy người dùng',
        message: 'Thử thay đổi từ khóa hoặc thêm người dùng mới.',
        icon: Icons.person_search_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: UserCard(
                user: user,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.userDetail,
                  arguments: user.email,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
