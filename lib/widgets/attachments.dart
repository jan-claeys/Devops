import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/attachment_opener.dart';
import '../services/logging.dart';
import 'work_item_visuals.dart';

final _log = Logger('Attachments');

/// From this size on, a download is confirmed first.
const largeAttachmentSize = 25 * 1024 * 1024;

/// A file on the Attachments tab. Images open in the app, other files are
/// downloaded and opened with the apps of the device.
class AttachmentTile extends StatefulWidget {
  const AttachmentTile(this.attachment, {super.key});

  final WorkItemAttachment attachment;

  @override
  State<AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<AttachmentTile> {
  bool _downloading = false;
  double? _progress;

  Future<void> _open() async {
    final attachment = widget.attachment;
    if (attachment.kind == AttachmentKind.image) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AttachmentImageScreen(attachment: attachment)));
      return;
    }
    await downloadAttachment(
      context,
      attachment,
      onStart: () => setState(() {
        _downloading = true;
        _progress = null;
      }),
      onProgress: (p) => mounted ? setState(() => _progress = p) : null,
    );
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final attachment = widget.attachment;
    final details = [
      if (attachment.size case final size?) formatFileSize(l10n, size),
      if (attachment.date != null) formatDateTime(l10n, attachment.date),
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Thumbnail(attachment),
      title: Text(attachment.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.isNotEmpty) Text(details),
          if (attachment.comment != null)
            Text(attachment.comment!, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (_downloading) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(value: _progress),
          ],
        ],
      ),
      trailing: Icon(attachment.kind == AttachmentKind.image
          ? Icons.chevron_right
          : Icons.download_outlined),
      onTap: _downloading ? null : _open,
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail(this.attachment);

  final WorkItemAttachment attachment;

  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        switch (attachment.kind) {
          AttachmentKind.image => Icons.image_outlined,
          AttachmentKind.video => Icons.movie_outlined,
          AttachmentKind.file when attachment.extension == 'pdf' =>
            Icons.picture_as_pdf_outlined,
          AttachmentKind.file => Icons.insert_drive_file_outlined,
        },
        color: scheme.onSurfaceVariant,
      ),
    );
    if (attachment.kind != AttachmentKind.image) return icon;
    final headers = AppScope.read(context).api?.headersFor(Uri.parse(attachment.url));
    if (headers == null) return icon;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        attachment.url,
        headers: headers,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        // Decoded small: a photo from a phone easily takes 50 MB decoded.
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (context, error, stackTrace) => icon,
      ),
    );
  }
}

/// The bytes of an image embedded in a `data:` URI, such as a screenshot
/// pasted into a field; null for any other URI or one that can't be decoded.
Uint8List? embeddedImage(Uri uri) {
  if (!uri.isScheme('data')) return null;
  try {
    return uri.data?.contentAsBytes();
  } on FormatException {
    return null;
  }
}

/// An image in a field or comment, opened full screen when tapped. Only
/// embedded images and images that [headers] returns headers for are loaded:
/// any other image could tell its server who opened the item and when. Those
/// show their alt text instead.
class InlineImage extends StatelessWidget {
  const InlineImage(this.uri, {super.key, this.alt, required this.headers});

  final Uri uri;
  final String? alt;
  final Map<String, String>? Function(Uri uri)? headers;

  /// Taller screenshots are scaled down; the full screen view shows them whole.
  static const maxHeight = 480.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = embeddedImage(uri);
    final embedded = uri.isScheme('data');
    // An embedded image's URI is its whole content: no text to show.
    final placeholder = Text(alt ?? (embedded ? '' : uri.toString()),
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    final imageHeaders = embedded ? null : headers?.call(uri);
    if (bytes == null && imageHeaders == null) return placeholder;
    final name = (embedded ? null : uri.queryParameters['fileName']) ??
        (alt?.trim().isNotEmpty ?? false
            ? alt!
            : embedded
                ? ''
                : uri.pathSegments.lastOrNull ?? '');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        // Decoded no wider than shown; smaller images keep their size.
        final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context)).round();
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: MouseRegion(
            cursor: SystemMouseCursors.zoomIn,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AttachmentImageScreen(
                    attachment: WorkItemAttachment(url: uri.toString(), name: name)),
              )),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: maxHeight),
                child: bytes != null
                    ? Image.memory(
                        bytes,
                        semanticLabel: alt,
                        fit: BoxFit.contain,
                        cacheWidth: cacheWidth,
                        errorBuilder: (context, error, stackTrace) => placeholder,
                      )
                    : Image.network(
                        uri.toString(),
                        headers: imageHeaders,
                        semanticLabel: alt,
                        fit: BoxFit.contain,
                        cacheWidth: cacheWidth,
                        errorBuilder: (context, error, stackTrace) => placeholder,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// An image attachment, to zoom in on.
class AttachmentImageScreen extends StatefulWidget {
  const AttachmentImageScreen({super.key, required this.attachment});

  final WorkItemAttachment attachment;

  @override
  State<AttachmentImageScreen> createState() => _AttachmentImageScreenState();
}

class _AttachmentImageScreenState extends State<AttachmentImageScreen> {
  bool _downloading = false;

  Future<void> _download() async {
    await downloadAttachment(context, widget.attachment,
        onStart: () => setState(() => _downloading = true));
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    final uri = Uri.parse(attachment.url);
    final bytes = embeddedImage(uri);
    final headers = uri.isScheme('data') ? null : AppScope.read(context).api?.headersFor(uri);
    final failed = Center(
      child: Icon(Icons.broken_image_outlined,
          size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
    final Widget? image = bytes != null
        ? Image.memory(
            bytes,
            semanticLabel: attachment.name,
            errorBuilder: (context, error, stackTrace) => failed,
          )
        : headers == null
            ? null
            : Image.network(
                attachment.url,
                headers: headers,
                semanticLabel: attachment.name,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes == null
                              ? null
                              : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) => failed,
              );
    return Scaffold(
      appBar: AppBar(
        title: Text(attachment.name),
        bottom: _downloading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
        actions: [
          // An embedded image is not stored as an attachment: nothing to download.
          if (bytes == null)
            IconButton(
              tooltip: context.l10n.openFile,
              icon: const Icon(Icons.download_outlined),
              onPressed: _downloading ? null : _download,
            ),
        ],
      ),
      body: image == null
          ? failed
          : InteractiveViewer(maxScale: 8, child: Center(child: image)),
    );
  }
}

/// Downloads [attachment] and opens it, after asking first when it is large;
/// [onStart] is called once the download starts. Failures are shown in a
/// snack bar.
Future<void> downloadAttachment(
  BuildContext context,
  WorkItemAttachment attachment, {
  VoidCallback? onStart,
  ValueChanged<double?>? onProgress,
}) async {
  final l10n = context.l10n;
  final api = AppScope.read(context).api;
  if (api == null) return;
  if ((attachment.size ?? 0) >= largeAttachmentSize &&
      !await _confirmLarge(context, attachment)) {
    return;
  }
  if (!context.mounted) return;
  onStart?.call();
  try {
    await openAttachment(api, attachment, onProgress: onProgress);
  } catch (e, st) {
    if (e is! NoAppForAttachment) {
      logFailure(_log, 'Opening attachment ${attachment.id} failed', e, st);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e is NoAppForAttachment ? l10n.noAppForFile : l10n.error(e)),
    ));
  }
}

Future<bool> _confirmLarge(BuildContext context, WorkItemAttachment attachment) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.downloadLargeTitle),
      content: Text(
          l10n.downloadLargeBody(attachment.name, formatFileSize(l10n, attachment.size!))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.download),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
