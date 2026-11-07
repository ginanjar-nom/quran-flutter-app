import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_firstaplication/main.dart';

void main() {
  testWidgets('Halaman utama Al-Qur’an Digital tampil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text("Al-Qur'an Digital"), findsOneWidget);
  });
}