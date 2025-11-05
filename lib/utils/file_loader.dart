import 'file_loader_io.dart'
    if (dart.library.html) 'file_loader_web.dart';

Future<String> readOtpFile(String path) {
  return readOtpFileImpl(path);
}
