import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('lib/data/static/egyptian_recipes.dart');
  if (!file.existsSync()) {
    stderr.writeln('ERROR: lib/data/static/egyptian_recipes.dart not found');
    exitCode = 1;
    return;
  }

  final content = file.readAsStringSync();

  final listStart = content.indexOf('[');
  if (listStart == -1) {
    stderr.writeln('ERROR: Could not find start of list');
    exitCode = 1;
    return;
  }

  var jsonPart = content.substring(listStart);
  jsonPart = jsonPart.substring(0, jsonPart.lastIndexOf('];') + 1);

  var result = StringBuffer();
  bool inString = false;
  for (int i = 0; i < jsonPart.length; i++) {
    final ch = jsonPart[i];
    if (ch == '"' && (i == 0 || jsonPart[i - 1] != '\\')) {
      inString = !inString;
      result.write(ch);
    } else if (!inString && ch == ',' && i + 1 < jsonPart.length) {
      var j = i + 1;
      while (j < jsonPart.length && (jsonPart[j] == ' ' || jsonPart[j] == '\n' || jsonPart[j] == '\r' || jsonPart[j] == '\t')) {
        j++;
      }
      if (j < jsonPart.length && (jsonPart[j] == '}' || jsonPart[j] == ']')) {
        result.write('');
      } else {
        result.write(ch);
      }
    } else if (!inString && ch == '/' && i + 1 < jsonPart.length && jsonPart[i + 1] == '/') {
      while (i < jsonPart.length && jsonPart[i] != '\n') i++;
    } else {
      result.write(ch);
    }
  }

  jsonPart = result.toString().trim();

  try {
    final parsed = jsonDecode(jsonPart);

    final minified = jsonEncode(parsed);
    final assetsDir = Directory('assets/data');
    if (!assetsDir.existsSync()) assetsDir.createSync();

    File('assets/data/recipes.json').writeAsStringSync(minified);
    final jsonKB = (minified.length / 1024).toStringAsFixed(1);
    print('JSON: assets/data/recipes.json ($jsonKB KB)');

    final gzipped = gzip.encode(utf8.encode(minified));
    File('assets/data/recipes.json.gz').writeAsBytesSync(gzipped);
    final gzKB = (gzipped.length / 1024).toStringAsFixed(1);
    final saved = ((1 - gzipped.length / minified.length) * 100).toStringAsFixed(1);
    print('GZip: assets/data/recipes.json.gz ($gzKB KB, saved $saved%)');
  } catch (e) {
    stderr.writeln('ERROR: Invalid JSON after transformation: $e');
    exitCode = 1;
  }
}
