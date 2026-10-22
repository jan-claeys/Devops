import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../models/work_item.dart';
import 'devops_api.dart';

/// Downloads [attachment] and hands it to the browser as a download: a link
/// to it would open without the token. [onProgress] gets the fraction
/// received, or null when the size is unknown.
Future<void> openAttachment(
  DevOpsApi api,
  WorkItemAttachment attachment, {
  ValueChanged<double?>? onProgress,
}) async {
  final response = await api.downloadAttachment(attachment);
  final total = response.contentLength ?? attachment.size;
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in response.stream) {
    bytes.add(chunk);
    onProgress?.call(total == null || total == 0 ? null : bytes.length / total);
  }
  final blob = web.Blob([bytes.takeBytes().toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href = url
    ..download = attachment.name
    ..click();
  // Revoked right away, some browsers cancel the download.
  Timer(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
}
