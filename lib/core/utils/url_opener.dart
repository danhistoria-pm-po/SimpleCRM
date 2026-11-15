// lib/core/utils/url_opener.dart
import 'url_opener_stub.dart'
    if (dart.library.js_interop) 'url_opener_web.dart' as impl;

Future<bool> openExternalUrl(String url) => impl.openUrlInNewTab(url);
