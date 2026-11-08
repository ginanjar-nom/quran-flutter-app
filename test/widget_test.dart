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

    expect(
      (surah['ayat'] as List).length,
      surah['jumlahAyat'],
      reason: 'Jumlah ayat surah nomor $nomor tidak sesuai',
    );
        final audioFull = surah['audioFull'] as Map<String, dynamic>;

    for (final kodeQari in ['02', '03', '04', '05', '06']) {
      final urlAudioFull = audioFull[kodeQari] as String?;

      expect(
        urlAudioFull?.trim().isNotEmpty ?? false,
        isTrue,
        reason: 'Audio penuh qari $kodeQari kosong pada surah $nomor',
      );
    }

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

      expect(
        (ayat['teksArab'] as String).trim().isNotEmpty,
        isTrue,
        reason: 'Teks Arab kosong pada surah $nomor ayat ${indeks + 1}',
      );

      expect(
        (ayat['teksIndonesia'] as String).trim().isNotEmpty,
        isTrue,
        reason: 'Terjemahan kosong pada surah $nomor ayat ${indeks + 1}',
      );

      final audio = ayat['audio'] as Map<String, dynamic>;

      for (final kodeQari in ['02', '03', '04', '05', '06']) {
        final urlAudio = audio[kodeQari] as String?;

        expect(
          urlAudio?.trim().isNotEmpty ?? false,
          isTrue,
          reason:
              'Audio qari $kodeQari kosong pada surah $nomor ayat ${indeks + 1}',
        );
      }
    }
  }
});
  testWidgets('Halaman utama Al-Qur’an Digital tampil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text("Al-Qur'an Digital"), findsOneWidget);
  });
}