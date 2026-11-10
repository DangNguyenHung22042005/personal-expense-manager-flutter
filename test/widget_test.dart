import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/app/app.dart';
import 'package:personal_expense_manager/app/app_providers.dart';
import 'package:personal_expense_manager/core/constants/app_strings.dart';
import 'package:personal_expense_manager/core/constants/demo_account.dart';
import 'package:personal_expense_manager/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:personal_expense_manager/features/users/data/repositories/in_memory_user_repository.dart';
import 'package:personal_expense_manager/features/users/data/seeds/sample_users.dart';

Widget buildTestApp() => AppProviders(
  authRepository: InMemoryAuthRepository(),
  userRepository: InMemoryUserRepository(initialUsers: SampleUsers.create()),
  child: const UserAdminApp(),
);

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('login-email-field')),
    DemoAccount.email,
  );
  await tester.enterText(
    find.byKey(const Key('login-password-field')),
    DemoAccount.password,
  );
  await tester.tap(find.byKey(const Key('login-button')));
  await tester.pumpAndSettle();
  expect(find.text('Tổng số người dùng'), findsOneWidget);
}

void main() {
  testWidgets('admin can sign in and sign out', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.tap(find.byKey(const Key('logout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-logout-button')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
  });

  testWidgets('admin can create, update and delete a user', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.tap(find.byKey(const Key('add-user-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('user-email-field')),
      'demo@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('user-password-field')),
      '123456',
    );
    await tester.enterText(
      find.byKey(const Key('user-name-field')),
      'Người Dùng Demo',
    );
    await tester.ensureVisible(find.byKey(const Key('save-user-button')));
    await tester.tap(find.byKey(const Key('save-user-button')));
    await tester.pumpAndSettle();
    expect(find.text('Người Dùng Demo'), findsOneWidget);
    await tester.tap(find.text('Người Dùng Demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-user-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('user-name-field')),
      'Người Dùng Đã Sửa',
    );
    await tester.ensureVisible(find.byKey(const Key('save-user-button')));
    await tester.tap(find.byKey(const Key('save-user-button')));
    await tester.pumpAndSettle();
    expect(find.text('Người Dùng Đã Sửa'), findsWidgets);
    await tester.tap(find.byKey(const Key('delete-user-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-user-button')));
    await tester.pumpAndSettle();
    expect(find.text('Người Dùng Đã Sửa'), findsNothing);
  });
}
