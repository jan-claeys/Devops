import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Azure DevOps links opened with the app or shared to it, and opening them
/// in the browser, on Android (MainActivity.kt).
class Links {
  static const _channel = MethodChannel('devops/links');

  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// The link the app was started with, then every link that arrives while
  /// it runs. Both arrive as text: a shared message may hold more than the
  /// link.
  static Stream<String> incoming() {
    final controller = StreamController<String>();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'link' && call.arguments is String) controller.add(call.arguments as String);
    });
    _channel.invokeMethod<String>('initialLink').then((text) {
      if (text != null) controller.add(text);
    }, onError: (Object _) {});
    controller.onCancel = () => _channel.setMethodCallHandler(null);
    return controller.stream;
  }

  /// Opens [url] in the browser. Once the user lets Android open Azure DevOps
  /// links with this app, an ordinary launch would come straight back here.
  static Future<bool> openInBrowser(Uri url) async {
    if (isSupported) {
      try {
        return await _channel.invokeMethod<bool>('openInBrowser', url.toString()) ?? false;
      } on MissingPluginException {
        // Not running in the app, as in tests.
      }
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
