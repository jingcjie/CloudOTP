import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> saveOtpJsonImpl({
  required String suggestedName,
  required String contents,
}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export OTP data',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
    return result;
  }

  final savePath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export OTP data',
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );

  if (savePath == null || savePath.isEmpty) {
    return null;
  }

  final file = File(savePath);
  await file.create(recursive: true);
  await file.writeAsString(contents);
  return file.path;
}
