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