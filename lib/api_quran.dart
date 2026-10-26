
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
