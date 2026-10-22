// Opens attachments with the apps of the device: downloaded to a file on
// Android, iOS and Windows, a download of the browser on the web.
export 'attachment_opener_io.dart' if (dart.library.js_interop) 'attachment_opener_web.dart';

/// Thrown when no app can open a downloaded attachment.
class NoAppForAttachment implements Exception {
  const NoAppForAttachment();
}
