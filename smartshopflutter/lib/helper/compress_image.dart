import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> compressImage(File file) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      "${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}",
    );

    // compressAndGetFile returns an XFile? – convert it to File
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    return result?.path != null ? File(result!.path) : null;
  } catch (e) {
    print("Error compressing image: $e");
    return null;
  }
}
