import 'dart:io';

import 'package:devops/models/work_item.dart';
import 'package:devops/services/attachment_opener_io.dart';
import 'package:devops/services/devops_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late FakeDevOps fake;
  late DevOpsApi api;
  late Directory cache;

  setUp(() async {
    fake = FakeDevOps();
    api = DevOpsApi(organization: 'contoso', pat: 'secret', client: fake.client);
    cache = await Directory.systemTemp.createTemp('attachments');
    addTearDown(() => cache.delete(recursive: true));
  });

  WorkItemAttachment attachment(String name, {int? size}) => WorkItem.fromJson(
          workItemJson(1, relations: [attachmentRelation(name, id: 'g1', size: size)]))
      .attachments
      .single;

  test('saves the file under its name and reports progress', () async {
    fake.attachments['g1'] = List.filled(1000, 7);
    final progress = <double?>[];
    final file = await saveAttachment(api, attachment('crash.mp4', size: 1000), cache,
        onProgress: progress.add);
    expect(file.path, endsWith('crash.mp4'));
    expect(await file.readAsBytes(), List.filled(1000, 7));
    expect(progress.last, 1.0);
    expect(cache.listSync(recursive: true).whereType<File>(), hasLength(1));
  });

  test('downloads a file only once', () async {
    fake.attachments['g1'] = [1, 2, 3];
    await saveAttachment(api, attachment('log.txt'), cache);
    final file = await saveAttachment(api, attachment('log.txt'), cache);
    expect(await file.readAsBytes(), [1, 2, 3]);
    expect(fake.requests, hasLength(1));
  });

  test('keeps nothing of a failed download', () async {
    await expectLater(
        saveAttachment(api, attachment('log.txt'), cache), throwsA(isA<DevOpsException>()));
    expect(cache.listSync(recursive: true).whereType<File>(), isEmpty);
  });

  test('safeFileName leaves no characters that a shell or path would act on', () {
    expect(safeFileName('Schermafbeelding 2026-10-20 é.png'), 'Schermafbeelding 2026-10-20 é.png');
    expect(safeFileName('x&calc.exe'), 'x_calc.exe');
    expect(safeFileName('%PATH%^"|<>.txt'), '_PATH______.txt');
    expect(safeFileName(r'..\..\evil.bat'), '_.._evil.bat');
    expect(safeFileName('../'), '_');
    expect(safeFileName('...'), 'attachment');
  });
}
