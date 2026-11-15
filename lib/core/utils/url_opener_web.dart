// lib/core/utils/url_opener_web.dart
import 'dart:js_interop';

@JS('window.open')
external JSAny? _windowOpen(JSString url, JSString target);

Future<bool> openUrlInNewTab(String url) async {
  try {
    _windowOpen(url.toJS, '_blank'.toJS);
    return true;
  } catch (_) {
    return false;
  }
}
