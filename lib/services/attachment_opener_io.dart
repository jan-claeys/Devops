import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/work_item.dart';
import 'attachment_opener.dart';
import 'devops_api.dart';

/// Downloads [attachment], unless it already was, and opens it with the app
/// the system picks for it. [onProgress] gets the fraction received, or null
/// when the size is unknown.
Future<void> openAttachment(
  DevOpsApi api,
  WorkItemAttachment attachment, {
  ValueChanged<double?>? onProgress,
}) async {
  final cache = Directory('${(await getTemporaryDirectory()).path}/attachments');
  final file = await saveAttachment(api, attachment, cache, onProgress: onProgress);
  final result = await OpenFilex.open(file.path);
  if (result.type == ResultType.noAppToOpen) throw const NoAppForAttachment();
  if (result.type != ResultType.done) throw FileSystemException(result.message, file.path);
}

/// The file of [attachment] in [cache], downloaded when it isn't there yet.
/// The content of an attachment never changes, so a complete file is kept.
@visibleForTesting
Future<File> saveAttachment(
  DevOpsApi api,
  WorkItemAttachment attachment,
  Directory cache, {
  ValueChanged<double?>? onProgress,
}) async {
  final dir = Directory('${cache.path}/${safeFileName(attachment.id)}');
  final file = File('${dir.path}/${safeFileName(attachment.name)}');
  if (await file.exists()) return file;

  final response = await api.downloadAttachment(attachment);
  await dir.create(recursive: true);
  // Written next to it first, so a broken download is never taken as the file.
  final part = File('${file.path}.part');
  final sink = part.openWrite();
  final total = response.contentLength ?? attachment.size;
  var received = 0;
  try {
    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      onProgress?.call(total == null || total == 0 ? null : received / total);
    }
    await sink.close();
  } catch (_) {
    await sink.close();
    await part.delete();
    rethrow;
  }
  return part.rename(file.path);
}

/// [name] with only letters, digits, spaces, dots, dashes and underscores.
/// The name comes from whoever attached the file, and Windows opens it
/// through `cmd`, where characters such as `&` or `%` would run commands.
@visibleForTesting
String safeFileName(String name) {
  final safe = name
      .replaceAll(RegExp(r'[^\p{L}\p{N} ._-]', unicode: true), '_')
      .replaceAll(RegExp(r'^[ .]+|[ .]+$'), '');
  return safe.isEmpty ? 'attachment' : safe;
}
