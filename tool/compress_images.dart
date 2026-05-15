import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
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

  int totalSaved = 0;
  int totalBytes = 0;

  for (final file in pngFiles) {
    final originalSize = file.lengthSync();
    totalBytes += originalSize;

    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        stderr.writeln('  SKIP (unable to decode): ${file.path}');
        continue;
      }

      final compressed = img.encodePng(image,
        level: 9,
        filter: img.PngFilter.paeth,
      );

      await file.writeAsBytes(compressed);
      final saved = originalSize - compressed.length;
      totalSaved += saved;
      final pct = ((saved / originalSize) * 100).toStringAsFixed(1);
      final fname = file.path.split(RegExp(r'[\\/]')).last;
      print('  $fname: ${_fmt(originalSize)} -> ${_fmt(compressed.length)} (saved $pct%)');
    } catch (e) {
      stderr.writeln('  ERROR on ${file.path}: $e');
    }
  }

  if (totalBytes > 0) {
    final totalPct = ((totalSaved / totalBytes) * 100).toStringAsFixed(1);
    print('\nTotal: ${_fmt(totalBytes)} -> ${_fmt(totalBytes - totalSaved)} (saved $totalPct%)');
  } else {
    print('\nNo images were processed.');
  }
}

String _fmt(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
