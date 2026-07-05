import 'package:flutter_test/flutter_test.dart';
import 'package:cake_shop/main.dart';
import 'package:cake_shop/services/api_service.dart';
import 'package:cake_shop/services/server_settings_service.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    final serverSettings = ServerSettingsService();
    await serverSettings.load();
    await tester.pumpWidget(CakeShopApp(
      apiService: ApiService(serverSettings: serverSettings),
      serverSettings: serverSettings,
    ));
    await tester.pump();
    expect(find.text('Sweet Delights'), findsOneWidget);
  });
}
