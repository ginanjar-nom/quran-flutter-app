import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_firstaplication/main.dart';
import 'package:flutter_firstaplication/data_quran_lokal.dart';

void main() {
  test('Seluruh 114 surah dapat dimuat', () async {
    for (int nomor = 1; nomor <= 114; nomor++) {
      final surah = await ambilDataSurahLokal(nomor);

      expect(
        surah['nomor'],
        nomor,
        reason: 'Surah nomor $nomor gagal dimuat',
      );
    }
  });

  testWidgets('Halaman utama Al-Qur’an Digital tampil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text("Al-Qur'an Digital"), findsOneWidget);
  });
}