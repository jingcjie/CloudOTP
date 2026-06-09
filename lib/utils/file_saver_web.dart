import 'dart:convert';
import 'dart:html' as html;

Future<String?> saveOtpJsonImpl({
  required String suggestedName,
  required String contents,
}) async {
  final bytes = utf8.encode(contents);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', suggestedName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return suggestedName;
}
