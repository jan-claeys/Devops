import 'package:devops/services/devops_api.dart';
import 'package:devops/widgets/error_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late FakeDevOps fake;

  setUp(() {
    mockStorage();
    fake = FakeDevOps();
  });

  Future<void> fail(WidgetTester tester, Object error) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showActionError(context, error, scopeHint: en.codeScopeHint),
            child: const Text('act'),
          ),
        ),
      ),
      state: connectedState(fake),
    );
    await tester.tap(find.text('act'));
    await tester.pump();
  }

  group('showActionError', () {
    testWidgets('names the scope when the token is refused', (tester) async {
      await fail(tester, DevOpsException(DevOpsError.unauthorized, statusCode: 401));
      expect(find.text('${en.actionDenied}\n${en.codeScopeHint}'), findsOneWidget);
    });

    testWidgets('adds what Azure DevOps says when permission is missing', (tester) async {
      await fail(tester,
          DevOpsException(DevOpsError.http, statusCode: 403, serverMessage: 'No permission'));
      expect(find.text('${en.actionDenied}\n${en.codeScopeHint}\nNo permission'), findsOneWidget);
    });

    testWidgets('shows other errors as they are', (tester) async {
      await fail(tester, DevOpsException(DevOpsError.http, statusCode: 409, serverMessage: 'Busy'));
      expect(find.text('Busy'), findsOneWidget);
    });
  });
}
