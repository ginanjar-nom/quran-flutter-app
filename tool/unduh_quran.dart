import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final List<Map<String, dynamic>> semuaSurah = [];

  for (int nomor = 1; nomor <= 114; nomor++) {
    final url = Uri.parse(
      'https://equran.id/api/v2/surat/$nomor',
    );

    final respons = await http
        .get(url)
        .timeout(const Duration(seconds: 30));

    if (respons.statusCode != 200) {
      throw Exception('Gagal mengunduh surah nomor $nomor');
    }

    final hasil =
        jsonDecode(respons.body) as Map<String, dynamic>;

    final data = Map<String, dynamic>.from(
      hasil['data'] as Map,
    );

    semuaSurah.add(data);

    stdout.writeln(
    'Berhasil: $nomor/114 - ${data['namaLatin']}',
     );

    await Future.delayed(
      const Duration(milliseconds: 250),
    );
  }

  final file = File('assets/data/quran_114.json');

  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(semuaSurah),
   );
   stdout.writeln('Selesai! Data 114 surah berhasil disimpan.');
  }