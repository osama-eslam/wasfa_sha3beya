import 'package:flutter_test/flutter_test.dart';
import 'package:wasfa_sha3beya/core/services/recipe_service.dart';
import 'package:wasfa_sha3beya/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    RecipeService.useSyncForTest = true;
    RecipeService.clearCache();

    await tester.pumpWidget(const MyApp());

    // Let async loading complete; avoid pumpAndSettle because
    // CachedNetworkImage will never resolve in the test environment.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('يا ترى هتاكل اي ؟'), findsOneWidget);
  });
}
