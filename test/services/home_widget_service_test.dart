import 'dart:convert';

import 'package:devops_tickets/models/work_item.dart';
import 'package:devops_tickets/services/home_widget_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late Map<String, Object?> saved;
  late int updates;

  void mockHomeWidget() {
    saved = {};
    updates = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map?;
      switch (call.method) {
        case 'saveWidgetData':
          saved[args!['id'] as String] = args['data'];
          return true;
        case 'getWidgetData':
          return saved[args!['id']];
        case 'updateWidget':
          expect(args!['android'], 'TicketsWidgetProvider');
          updates++;
          return true;
      }
      return null;
    });
  }

  setUp(mockHomeWidget);
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('workItemIdFromUri reads widget deep links', () {
    expect(TicketsHomeWidget.workItemIdFromUri(Uri.parse('devopstickets://workitem/123')),
        123);
    expect(TicketsHomeWidget.workItemIdFromUri(null), isNull);
    expect(TicketsHomeWidget.workItemIdFromUri(Uri.parse('devopstickets://workitem')),
        isNull);
    expect(TicketsHomeWidget.workItemIdFromUri(Uri.parse('devopstickets://other/1')),
        isNull);
    expect(TicketsHomeWidget.workItemIdFromUri(Uri.parse('devopstickets://workitem/abc')),
        isNull);
  });

  test('update stores at most 50 tickets and the total count', () async {
    final items = [
      for (var i = 1; i <= 60; i++)
        WorkItem.fromJson(workItemJson(i, title: 'T$i', state: 'New', type: 'Task')),
    ];
    await TicketsHomeWidget.update(project: 'Contoso', items: items);

    final stored = jsonDecode(saved['items'] as String) as List;
    expect(stored, hasLength(50));
    expect(stored.first, {'id': 1, 'title': 'T1', 'state': 'New', 'type': 'Task'});
    expect(saved['count'], 60);
    expect(saved['project'], 'Contoso');
    expect(saved['error'], isNull);
    expect(int.tryParse(saved['updatedAt'] as String), isNotNull);
    expect(updates, 1);
  });

  test('update with only an error keeps the previous tickets', () async {
    saved['items'] = '[{"id":1}]';
    await TicketsHomeWidget.update(project: 'Contoso', error: 'Offline');
    expect(saved['items'], '[{"id":1}]');
    expect(saved['error'], 'Offline');
  });

  test('update ignores platforms without widget support', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await TicketsHomeWidget.update(project: 'Contoso', items: const []);
  });

  test('refresh asks to set up the app when not configured', () async {
    mockStorage();
    await TicketsHomeWidget.refresh();
    expect(saved['error'], en.widgetSetupRequired);
    expect(saved['items'], '[]');
    expect(updates, 1);
  });

  test('refresh stores my open tickets', () async {
    final fake = FakeDevOps()..add(workItemJson(7, title: 'Fix login'));
    await TicketsHomeWidget.refresh(connectedState(fake));

    final query = jsonDecode(fake.requests.first.body)['query'] as String;
    expect(query, contains('[System.AssignedTo] = @me'));
    expect(query, contains('NOT IN'));
    expect((jsonDecode(saved['items'] as String) as List).single['title'], 'Fix login');
    expect(saved['error'], isNull);
  });

  test('refresh shows a translated error', () async {
    final fake = FakeDevOps()..failWith = 401;
    await TicketsHomeWidget.refresh(connectedState(fake));
    expect(saved['error'], en.errorUnauthorized);
    expect(saved['project'], 'Contoso');
  });
}
