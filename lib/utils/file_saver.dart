import 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';

Future<String?> saveOtpJson({
  required String suggestedName,
  required String contents,
}) {
  return saveOtpJsonImpl(
    suggestedName: suggestedName,
    contents: contents,
  );
}
