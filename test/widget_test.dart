import 'package:flutter_test/flutter_test.dart';
import 'package:athkari_app/main.dart';
import 'package:athkari_app/core/theme/theme_controller.dart';
void main() {
  testWidgets('Athkari app test', (WidgetTester tester) async {
    await tester.pumpWidget(
      AthkariApp(
        themeController: ThemeController(),
      ),
    );
  });
}