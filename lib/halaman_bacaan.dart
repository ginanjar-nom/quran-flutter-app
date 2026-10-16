import 'package:flutter/material.dart';
import 'data_surah.dart';

class HalamanBacaan extends StatelessWidget {
  final String namaSurah;

  const HalamanBacaan({
    super.key,
    required this.namaSurah,
  });

  @override
  Widget build(BuildContext context) {
    // Memilih data ayat berdasarkan nama surah.
    final List<Map<String, dynamic>> daftarAyat;

    if (namaSurah == 'Al-Baqarah') {
      daftarAyat = dataAyatBaqarah;
    } else {
      daftarAyat = dataAyatFatihah;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(namaSurah),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ...daftarAyat.map((ayat) {
                return Column(
                  children: [
                    Text(
                      ayat['arab'],
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Ayat ${ayat['nomor']}'),
                    const SizedBox(height: 8),
                    Text(
                      ayat['terjemahan'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}