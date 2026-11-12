import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<dynamic>>? _dataQuranFuture;

Future<Map<String, dynamic>> ambilDataSurahLokal(
  int nomorSurah,
) async {
  _dataQuranFuture ??= rootBundle
      .loadString('assets/data/quran_114.json')
      .then((data) => jsonDecode(data) as List<dynamic>);

  final semuaSurah = await _dataQuranFuture!;

  final hasil = semuaSurah.firstWhere(
    (surah) => surah['nomor'] == nomorSurah,
  );

  return Map<String, dynamic>.from(hasil as Map);
}

  Future<List<Map<String, dynamic>>> ambilDaftarSurahLokal() async {
  _dataQuranFuture ??= rootBundle
      .loadString('assets/data/quran_114.json')
      .then((data) => jsonDecode(data) as List<dynamic>);

  final semuaSurah = await _dataQuranFuture!;

  return semuaSurah.map((surah) {
    final data = Map<String, dynamic>.from(surah as Map);

    return {
      'nomor': data['nomor'],
      'nama': data['nama'],
      'namaArab': data['namaArab'],
      'jumlahAyat': data['jumlahAyat'],
    };
  }).toList();
}