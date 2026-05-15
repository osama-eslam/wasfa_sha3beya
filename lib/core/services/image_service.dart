import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  ImageService._();

  /// 30-day persistent cache for recipe images.
  static final BaseCacheManager _recipeCacheManager = CacheManager(
    Config(
      'recipe_images',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 500,
    ),
  );

  /// Three local placeholder assets displayed randomly while the Supabase
  /// image is loading. The choice is deterministic per recipe via [seed].
  static const List<String> _placeholderAssets = [
    'assets/images/all.png',
    'assets/images/all1.png',
    'assets/images/all2.png',
  ];

  static Widget assetImage(String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    int? cacheWidth,
    int? cacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
    Color? color,
    BlendMode? colorBlendMode,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: filterQuality,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: errorBuilder,
    );
  }

  /// Displays a recipe image from the Supabase URL with:
  /// - 30-day disk cache ([_recipeCacheManager])
  /// - A random local placeholder ([all.png] / [all1.png] / [all2.png])
  /// - A [fadeInDuration] transition when the real image arrives
  static Widget networkImage(String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    final placeholderPath = _placeholderAssets[Random().nextInt(3)];

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _recipeCacheManager,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 400),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => Image.asset(
        placeholderPath,
        width: width,
        height: height,
        fit: fit,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  static Future<Uint8List?> compressBytes(Uint8List data,
      {int quality = 85, int minWidth = 0, int minHeight = 0}) async {
    return FlutterImageCompress.compressWithList(
      data,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }

  static const int gridThumbnailWidth = 300;
  static const int detailImageWidth = 600;

  static Future<String> getCompressedAssetPath(String assetPath) async {
    final dir = await getTemporaryDirectory();
    final name = assetPath.split('/').last;
    final ext = name.contains('.') ? name.split('.').last : 'png';
    final baseName = name.replaceAll('.$ext', '');
    final cachePath = '${dir.path}/${baseName}_compressed.$ext';

    final file = File(cachePath);
    if (file.existsSync()) return cachePath;

    final bundleData = await rootBundle.load(assetPath);
    final bytes = bundleData.buffer.asUint8List();
    final compressed = await compressBytes(bytes, quality: 85);
    if (compressed == null) return assetPath;

    await file.writeAsBytes(compressed);
    return cachePath;
  }
}
