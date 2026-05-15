import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../data/models/recipe.dart';

/// Singleton service that loads, decompresses, and parses recipe data
/// off the main isolate to keep the UI at 60 FPS.
///
/// Load order:
///   1. [recipes.json.gz] (GZip compressed, preferred)
///   2. [recipes.json]     (plain JSON, fallback)
///
/// Results are cached after the first successful load so subsequent
/// calls return immediately.
class RecipeService {
  RecipeService._();

  static final RecipeService _instance = RecipeService._();

  /// Returns the singleton instance.
  factory RecipeService() => _instance;

  List<Recipe>? _cached;
  Future<List<Recipe>>? _loadFuture;

  static const String _gzipAssetPath = 'assets/data/recipes.json.gz';
  static const String _fallbackAssetPath = 'assets/data/recipes.json';

  @visibleForTesting
  static bool useSyncForTest = false;

  @visibleForTesting
  static void clearCache() {
    _instance._cached = null;
    _instance._loadFuture = null;
  }

  /// Returns every recipe as a [List<Recipe>].
  ///
  /// The first call performs the actual load (decompress + parse + map).
  /// Subsequent calls return the cached list immediately.
  Future<List<Recipe>> getAllRecipes() async {
    if (_cached != null) return _cached!;
    _loadFuture ??= _loadInternal();
    return _loadFuture!;
  }

  /// Re-loads data from assets, bypassing the cache.
  ///
  /// Useful when the asset has been hot-reloaded or when a forced refresh
  /// is needed (e.g. after a locale change or a debug re-build).
  Future<List<Recipe>> refresh() async {
    _cached = null;
    _loadFuture = null;
    return getAllRecipes();
  }

  // ---------------------------------------------------------------------------
  // Internal loading pipeline
  // ---------------------------------------------------------------------------

  Future<List<Recipe>> _loadInternal() async {
    List<Map<String, dynamic>>? raw;

    raw ??= await _loadFromGzip();
    raw ??= await _loadFromPlainJson();

    if (raw == null) {
      throw RecipeServiceException(
        'All load strategies failed. '
        'Ensure at least $_gzipAssetPath or $_fallbackAssetPath exists.',
      );
    }

    final recipes = raw
        .asMap()
        .entries
        .map((e) => Recipe.fromMap(e.value, e.key))
        .toList();

    _cached = List.unmodifiable(recipes);
    return _cached!;
  }

  /// Tries to load and parse [recipes.json.gz].
  Future<List<Map<String, dynamic>>?> _loadFromGzip() async {
    ByteData assetData;

    try {
      assetData = await rootBundle.load(_gzipAssetPath);
    } on FlutterError catch (e) {
      debugPrint('RecipeService: $_gzipAssetPath not found — $e');
      return null;
    } catch (e) {
      debugPrint('RecipeService: $_gzipAssetPath load error — $e');
      return null;
    }

    final bytes = Uint8List.fromList(assetData.buffer.asUint8List());

    final sw = Stopwatch()..start();

    try {
      final List<Map<String, dynamic>> result;

      if (useSyncForTest) {
        result = _decompressGzipSync(bytes);
      } else {
        result = await Isolate.run(() => _decompressGzipSync(bytes));
      }

      sw.stop();
      debugPrint(
        'RecipeService: GZip → ${result.length} recipes in '
        '${sw.elapsedMilliseconds}ms',
      );
      return result;
    } catch (e) {
      debugPrint('RecipeService: GZip decode/parse failed — $e');
      return null;
    }
  }

  /// Tries to load and parse [recipes.json] (uncompressed fallback).
  Future<List<Map<String, dynamic>>?> _loadFromPlainJson() async {
    ByteData assetData;

    try {
      assetData = await rootBundle.load(_fallbackAssetPath);
    } on FlutterError catch (e) {
      debugPrint('RecipeService: $_fallbackAssetPath not found — $e');
      return null;
    } catch (e) {
      debugPrint('RecipeService: $_fallbackAssetPath load error — $e');
      return null;
    }

    final bytes = Uint8List.fromList(assetData.buffer.asUint8List());

    try {
      final List<Map<String, dynamic>> result;

      if (useSyncForTest) {
        result = _parseJsonSync(bytes);
      } else {
        result = await Isolate.run(() => _parseJsonSync(bytes));
      }

      debugPrint('RecipeService: Plain JSON → ${result.length} recipes');
      return result;
    } catch (e) {
      debugPrint('RecipeService: Fallback JSON parse failed — $e');
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Top-level helpers (required by Isolate.run)
// ---------------------------------------------------------------------------

/// Decompresses [bytes] with GZip, decodes to UTF-8, and parses as JSON.
///
/// Must be a top-level function so it can be sent to [Isolate.run].
List<Map<String, dynamic>> _decompressGzipSync(Uint8List bytes) {
  final decoded = GZipCodec().decode(bytes);
  final jsonString = utf8.decode(decoded);
  final List parsed = jsonDecode(jsonString);
  return parsed.cast<Map<String, dynamic>>();
}

/// Decodes [bytes] as UTF-8 and parses as JSON.
///
/// Must be a top-level function so it can be sent to [Isolate.run].
List<Map<String, dynamic>> _parseJsonSync(Uint8List bytes) {
  final jsonString = utf8.decode(bytes);
  final List parsed = jsonDecode(jsonString);
  return parsed.cast<Map<String, dynamic>>();
}

// ---------------------------------------------------------------------------
// Custom exception
// ---------------------------------------------------------------------------

/// Thrown when the recipe service cannot load data from any configured source.
class RecipeServiceException implements Exception {
  final String message;
  const RecipeServiceException(this.message);

  @override
  String toString() => 'RecipeServiceException: $message';
}
