import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class DataService {
  DataService._();

  static const String _gzipPath = 'assets/data/recipes.json.gz';
  static const String _plainJsonPath = 'assets/data/recipes.json';

  static List<Map<String, dynamic>>? _cached;

  @visibleForTesting
  static bool useSyncForTest = false;

  static void clearCache() {
    _cached = null;
  }

  static Future<List<Map<String, dynamic>>> loadRecipes() async {
    if (_cached != null) return _cached!;

    List<Map<String, dynamic>>? result;

    result ??= await _tryGzip();
    result ??= await _tryPlainJson();

    if (result == null) {
      debugPrint('DataService: All load strategies failed');
      return [];
    }

    _cached = result;
    return _cached!;
  }

  static Future<List<Map<String, dynamic>>?> _tryGzip() async {
    try {
      final data = await rootBundle.load(_gzipPath);
      final bytes = Uint8List.fromList(data.buffer.asUint8List());

      final sw = Stopwatch()..start();
      final List<Map<String, dynamic>> result;

      if (useSyncForTest) {
        final decoded = GZipCodec().decode(bytes);
        final jsonString = utf8.decode(decoded);
        final List parsed = jsonDecode(jsonString);
        result = parsed.cast<Map<String, dynamic>>();
      } else {
        result = await Isolate.run(() {
          final decoded = GZipCodec().decode(bytes);
          final jsonString = utf8.decode(decoded);
          final List parsed = jsonDecode(jsonString);
          return parsed.cast<Map<String, dynamic>>();
        });
      }

      sw.stop();
      debugPrint('DataService: GZip → ${result.length} recipes in ${sw.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      debugPrint('DataService: GZip error — $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> _tryPlainJson() async {
    try {
      final data = await rootBundle.load(_plainJsonPath);
      final bytes = Uint8List.fromList(data.buffer.asUint8List());

      final List<Map<String, dynamic>> result;

      if (useSyncForTest) {
        final jsonString = utf8.decode(bytes);
        final List parsed = jsonDecode(jsonString);
        result = parsed.cast<Map<String, dynamic>>();
      } else {
        result = await Isolate.run(() {
          final jsonString = utf8.decode(bytes);
          final List parsed = jsonDecode(jsonString);
          return parsed.cast<Map<String, dynamic>>();
        });
      }

      debugPrint('DataService: Plain JSON → ${result.length} recipes');
      return result;
    } catch (e) {
      debugPrint('DataService: Plain JSON error — $e');
      return null;
    }
  }
}
