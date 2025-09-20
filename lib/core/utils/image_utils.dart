import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File> compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return file;

    // Target width for compressed images (maintain aspect ratio)
    const targetWidth = 1024;

    // Calculate new dimensions
    final ratio = image.width / image.height;
    final targetHeight = (targetWidth / ratio).round();

    // Resize image
    final resized = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // Convert to jpg with quality setting
    final compressed = img.encodeJpg(resized, quality: 85);

    // Save compressed image
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }
}
