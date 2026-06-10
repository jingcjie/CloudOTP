import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String?> saveOtpJsonImpl({
  required String suggestedName,
  required String contents,
}) async {
  final blob = web.Blob(
    [contents.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = suggestedName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return suggestedName;
}
