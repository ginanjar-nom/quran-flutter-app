import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_firstaplication/main.dart';
import 'package:flutter_firstaplication/data_quran_lokal.dart';

void main() {
  test('Seluruh 114 surah dapat dimuat', () async {
    for (int nomor = 1; nomor <= 114; nomor++) {
    final surah = await ambilDataSurahLokal(nomor);
     expect(
       (surah['ayat'] as List).length,
        surah['jumlahAyat'],
        reason: 'Jumlah ayat surah nomor $nomor tidak sesuai',
 );
   for (int indeks = 0;
    indeks < (surah['ayat'] as List).length;
    indeks++) {
  final ayat = surah['ayat'][indeks];

     expect(
        ayat['nomorAyat'],
        indeks + 1,
        reason:
        'Nomor ayat ${indeks + 1} pada surah $nomor tidak sesuai',
  );
}
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