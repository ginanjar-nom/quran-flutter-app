import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_firstaplication/main.dart';
import 'package:flutter_firstaplication/data_quran_lokal.dart';
void main() {
    test('Data lokal dapat memuat surah pertama dan terakhir', () async {
    final surahPertama = await ambilDataSurahLokal(1);
    final surahTerakhir = await ambilDataSurahLokal(114);

    expect(surahPertama['nomor'], 1);
    expect(surahTerakhir['nomor'], 114);
  });
  testWidgets('Halaman utama Al-Qur’an Digital tampil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text("Al-Qur'an Digital"), findsOneWidget);
  });
}