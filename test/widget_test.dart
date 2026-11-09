import 'package:flutter_test/flutter_test.dart';

import 'package:personal_expense_manager/app/app.dart';
import 'package:personal_expense_manager/app/app_providers.dart';
import 'package:personal_expense_manager/core/constants/app_strings.dart';

void main() {
  testWidgets('FinTrack opens and navigates to transaction history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: FinTrackApp()));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.currentBalance), findsOneWidget);

    await tester.tap(find.text(AppStrings.viewTransactions));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionHistory), findsOneWidget);
    expect(find.text(AppStrings.noTransactionsTitle), findsOneWidget);
  });
}
