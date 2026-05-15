import 'package:wasfa_sha3beya/core/services/data_service.dart';

Future<List<Map<String, dynamic>>> loadEgyptianRecipes() {
  return DataService.loadRecipes();
}
