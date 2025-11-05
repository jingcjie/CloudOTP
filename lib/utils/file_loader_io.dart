import 'dart:io';

Future<String> readOtpFileImpl(String path) async {
  final file = File(path);
  return file.readAsString();
}
