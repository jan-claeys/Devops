import 'package:devops/models/work_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('Identity', () {
    test('fromJson reads an identity object', () {
      final identity = Identity.fromJson({
        'displayName': 'Jan Claeys',
        'uniqueName': 'jan@contoso.com',
        'imageUrl': 'https://example.com/a.png',
      })!;
      expect(identity.displayName, 'Jan Claeys');
      expect(identity.uniqueName, 'jan@contoso.com');
      expect(identity.imageUrl, 'https://example.com/a.png');
    });

    test('fromJson accepts a plain name string', () {
      expect(Identity.fromJson('Jan Claeys')!.displayName, 'Jan Claeys');
    });

    test('fromJson returns null for missing or empty values', () {
      expect(Identity.fromJson(null), isNull);
      expect(Identity.fromJson(''), isNull);
      expect(Identity.fromJson(42), isNull);
    });

    test('fromJson tolerates a missing display name', () {
      expect(Identity.fromJson(<String, dynamic>{})!.displayName, '');
    });

    test('initials use the first and last name', () {
      expect(const Identity(displayName: 'jan claeys').initials, 'JC');
      expect(const Identity(displayName: 'Jan van den Berg').initials, 'JB');
      expect(const Identity(displayName: '  Jan  ').initials, 'J');
      expect(const Identity(displayName: '').initials, '?');
      expect(const Identity(displayName: '   ').initials, '?');
    });
  });

  group('WorkItem', () {
    test('fromJson reads id, fields and relations', () {
      final item = WorkItem.fromJson(workItemJson(
        7,
        relations: [relation('System.LinkTypes.Hierarchy-Reverse', 3)],
      ));
      expect(item.id, 7);
      expect(item.title, 'Ticket');
      expect(item.state, 'Active');
      expect(item.type, 'Bug');
      expect(item.project, 'Contoso');
      expect(item.relations, hasLength(1));
    });

    test('fromJson tolerates missing fields and relations', () {
      final item = WorkItem.fromJson({'id': 5});
      expect(item.title, '#5');
      expect(item.state, '');
      expect(item.type, '');
      expect(item.project, '');
      expect(item.assignedTo, isNull);
      expect(item.priority, isNull);
      expect(item.tags, isEmpty);
      expect(item.parentId, isNull);
      expect(item.childIds, isEmpty);
    });

    test('reads optional text fields', () {
      final item = WorkItem(id: 1, fields: {
        'System.Reason': 'New',
        'System.AreaPath': 'Contoso\\Web',
        'System.IterationPath': 'Contoso\\Sprint 1',
        'System.Description': '<p>desc</p>',
        'Microsoft.VSTS.TCM.ReproSteps': '<p>steps</p>',
        'Microsoft.VSTS.Common.AcceptanceCriteria': '<p>done</p>',
      });
      expect(item.reason, 'New');
      expect(item.areaPath, 'Contoso\\Web');
      expect(item.iterationPath, 'Contoso\\Sprint 1');
      expect(item.description, '<p>desc</p>');
      expect(item.reproSteps, '<p>steps</p>');
      expect(item.acceptanceCriteria, '<p>done</p>');
    });

    test('reads people', () {
      final item = WorkItem(id: 1, fields: {
        'System.AssignedTo': {'displayName': 'Jan'},
        'System.CreatedBy': 'Piet',
      });
      expect(item.assignedTo!.displayName, 'Jan');
      expect(item.createdBy!.displayName, 'Piet');
    });

    test('parses dates as local time', () {
      final item = WorkItem(id: 1, fields: {
        'System.CreatedDate': '2026-01-02T10:00:00Z',
        'System.ChangedDate': 'not a date',
      });
      expect(item.createdDate, DateTime.utc(2026, 1, 2, 10).toLocal());
      expect(item.createdDate!.isUtc, isFalse);
      expect(item.changedDate, isNull);
    });

    test('reads numeric scheduling fields', () {
      final item = WorkItem(id: 1, fields: {
        'Microsoft.VSTS.Common.Priority': 2.0,
        'Microsoft.VSTS.Scheduling.OriginalEstimate': 8,
        'Microsoft.VSTS.Scheduling.RemainingWork': 2.5,
        'Microsoft.VSTS.Scheduling.CompletedWork': 5.5,
      });
      expect(item.priority, 2);
      expect(item.originalEstimate, 8);
      expect(item.remainingWork, 2.5);
      expect(item.completedWork, 5.5);
    });

    test('story points fall back to effort', () {
      expect(
          WorkItem(id: 1, fields: {'Microsoft.VSTS.Scheduling.StoryPoints': 3})
              .storyPoints,
          3);
      expect(WorkItem(id: 1, fields: {'Microsoft.VSTS.Scheduling.Effort': 5}).storyPoints,
          5);
      expect(WorkItem(id: 1, fields: {}).storyPoints, isNull);
    });

    test('splits and trims tags', () {
      expect(WorkItem(id: 1, fields: {'System.Tags': 'ui; backend ;;  urgent'}).tags,
          ['ui', 'backend', 'urgent']);
      expect(WorkItem(id: 1, fields: {'System.Tags': '   '}).tags, isEmpty);
    });

    test('parentId prefers System.Parent over relations', () {
      final item = WorkItem(
        id: 1,
        fields: {'System.Parent': 10},
        relations: [relation('System.LinkTypes.Hierarchy-Reverse', 20)],
      );
      expect(item.parentId, 10);
    });

    test('parentId and childIds come from hierarchy relations', () {
      final item = WorkItem(id: 1, fields: {}, relations: [
        relation('System.LinkTypes.Hierarchy-Reverse', 20),
        relation('System.LinkTypes.Hierarchy-Forward', 30),
        relation('System.LinkTypes.Related', 40),
        relation('System.LinkTypes.Hierarchy-Forward', 31),
      ]);
      expect(item.parentId, 20);
      expect(item.childIds, [30, 31]);
    });

    test('childIds skips relation urls without a numeric id', () {
      final item = WorkItem(id: 1, fields: {}, relations: [
        {'rel': 'System.LinkTypes.Hierarchy-Forward', 'url': 'https://x/abc'},
        relation('System.LinkTypes.Hierarchy-Forward', 30),
      ]);
      expect(item.childIds, [30]);
    });
  });

  test('WorkItemComment.fromJson', () {
    final comment = WorkItemComment.fromJson({
      'text': '<p>Hi</p>',
      'createdBy': {'displayName': 'Jan'},
      'createdDate': '2026-03-04T05:06:07Z',
    });
    expect(comment.text, '<p>Hi</p>');
    expect(comment.createdBy!.displayName, 'Jan');
    expect(comment.createdDate, DateTime.utc(2026, 3, 4, 5, 6, 7).toLocal());

    final empty = WorkItemComment.fromJson({});
    expect(empty.text, '');
    expect(empty.createdBy, isNull);
    expect(empty.createdDate, isNull);
  });

  test('Project.fromJson', () {
    final project =
        Project.fromJson({'id': 'abc', 'name': 'Contoso', 'description': 'Main'});
    expect(project.id, 'abc');
    expect(project.name, 'Contoso');
    expect(project.description, 'Main');
    expect(Project.fromJson({'id': 'x', 'name': 'Y'}).description, isNull);
  });
}
