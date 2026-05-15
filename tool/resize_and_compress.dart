import 'dart:io';
import 'package:image/image.dart' as img;

const int maxWidth = 800;
const int maxHeight = 800;

void main() {
  final assetDir = Directory('assets/images');
  if (!assetDir.existsSync()) {
    stderr.writeln('ERROR: assets/images/ not found');
    exitCode = 1;
    return;
  }

  final pngFiles = assetDir.listSync().whereType<File>().where(
    (f) => f.path.toLowerCase().endsWith('.png'),
  ).toList();

  if (pngFiles.isEmpty) {
    print('No PNG files found in assets/images/');
    return;
  }

  int totalOriginal = 0;
  int totalNew = 0;

  for (final file in pngFiles) {
    final originalSize = file.lengthSync();
    totalOriginal += originalSize;
    final fname = file.path.split(RegExp(r'[\\/]')).last;

    try {
      final bytes = file.readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) {
        stderr.writeln('  SKIP (unable to decode): $fname');
        continue;
      }

      final srcW = image.width;
      final srcH = image.height;

      if (srcW <= maxWidth && srcH <= maxHeight) {
        final pct = ((1 - bytes.length / originalSize) * 100).toStringAsFixed(1);
        totalNew += bytes.length;
        print('  $fname: ${_fmt(originalSize)} -> ${_fmt(bytes.length)} (compressed $pct%) already ${srcW}x$srcH');
        continue;
      }

      final scale = (srcW > srcH)
          ? maxWidth / srcW
          : maxHeight / srcH;
      final newW = (srcW * scale).round();
      final newH = (srcH * scale).round();

      final resized = img.copyResize(image, width: newW, height: newH);
      final outBytes = img.encodePng(resized, level: 9, filter: img.PngFilter.paeth);

      file.writeAsBytesSync(outBytes);

      final saved = originalSize - outBytes.length;
      totalNew += outBytes.length;
      final pct = ((saved / originalSize) * 100).toStringAsFixed(1);
      print('  $fname: ${_fmt(originalSize)} -> ${_fmt(outBytes.length)} (saved $pct%) ${srcW}x$srcH -> ${newW}x$newH');
    } catch (e) {
      stderr.writeln('  ERROR on $fname: $e');
    }
  }

  if (totalOriginal > 0) {
    final totalPct = ((1 - totalNew / totalOriginal) * 100).toStringAsFixed(1);
    print('\nTotal: ${_fmt(totalOriginal)} -> ${_fmt(totalNew)} (saved $totalPct%)');
  }
}

String _fmt(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
