import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_expense_manager/app/app.dart';
import 'package:personal_expense_manager/app/app_providers.dart';
import 'package:personal_expense_manager/core/constants/app_strings.dart';

void main() {
  testWidgets('dashboard, transaction list, and search use controller data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: FinTrackApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.currentBalance), findsOneWidget);
    expect(find.text('Cà phê buổi sáng'), findsOneWidget);

    await tester.tap(find.text(AppStrings.viewTransactions));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionHistory), findsOneWidget);
    expect(find.text('Cà phê buổi sáng'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('transaction-search-field')),
      'Flutter',
    );
    await tester.pump();

    expect(find.text('Khóa học Flutter'), findsOneWidget);
    expect(find.text('Lương tháng này'), findsNothing);
  });

  testWidgets('user can create, read, update, and delete a transaction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: FinTrackApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-transaction-button')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addTransaction), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('transaction-title-field')),
      'Bán đồ cũ',
    );
    await tester.enterText(
      find.byKey(const Key('transaction-amount-field')),
      '750000',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('save-transaction-button')),
    );
    await tester.tap(find.byKey(const Key('save-transaction-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bán đồ cũ'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bán đồ cũ'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionDetail), findsOneWidget);
    expect(find.text('-750.000 ₫'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-transaction-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('transaction-title-field')),
      'Bán đồ cũ đã sửa',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('save-transaction-button')),
    );
    await tester.tap(find.byKey(const Key('save-transaction-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bán đồ cũ đã sửa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-transaction-button')));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận xóa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-delete-button')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text('Bán đồ cũ đã sửa'), findsNothing);
    expect(find.text('Đã xóa giao dịch thành công.'), findsOneWidget);
  });

  testWidgets('compact phone layout renders without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AppProviders(child: FinTrackApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.currentBalance), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-transaction-button')));
    await tester.pumpAndSettle();

    expect(find.text('Chi'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet layout follows system dark mode without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 800));
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    addTearDown(() async {
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const AppProviders(child: FinTrackApp()));
    await tester.pumpAndSettle();

    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffoldContext).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.viewTransactions));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionHistory), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
