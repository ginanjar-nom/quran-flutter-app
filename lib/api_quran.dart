
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> ambilDataSurah(int nomorSurah) async {
  final url = Uri.parse(
    'https://equran.id/api/v2/surat/$nomorSurah',
  );

  final respons = await http.get(url);

  if (respons.statusCode != 200) {
    throw Exception('Gagal mengambil data surah');
  }

  final hasil = jsonDecode(respons.body) as Map<String, dynamic>;

  return hasil['data'] as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> ambilDaftarSurah() async {
  final url = Uri.parse('https://equran.id/api/v2/surat');
  final respons = await http.get(url);

  if (respons.statusCode != 200) {
    throw Exception('Gagal mengambil daftar surah');
  }

  final hasil = jsonDecode(respons.body) as Map<String, dynamic>;
  final data = hasil['data'] as List<dynamic>;

  return data.map((surah) {
    return {
      'nomor': surah['nomor'],
      'nama': surah['namaLatin'],
      'namaArab': surah['nama'],
      'jumlahAyat': surah['jumlahAyat'],
    };
  }).toList();
}


Future<void> unduhSemuaSurah({
  required Future<void> Function(
    int nomorSurah,
    Map<String, dynamic> data,
  ) simpanData,
  required void Function(int selesai) saatProgres,
}) async {
  for (int nomor = 1; nomor <= 114; nomor++) {
    final hasil = await ambilDataSurah(nomor);
    await simpanData(nomor, hasil);
    saatProgres(nomor);
  }
}
