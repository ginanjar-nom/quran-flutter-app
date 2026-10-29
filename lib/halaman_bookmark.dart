import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_bacaan.dart';
import 'data_surah.dart';
import 'dart:convert';



class HalamanBookmark extends StatefulWidget {
  const HalamanBookmark({super.key});

  @override
  State<HalamanBookmark> createState() =>
      _HalamanBookmarkState();
}

class _HalamanBookmarkState extends State<HalamanBookmark> {
  List<String> daftarFavorit = [];
  Map<String, int> penandaAyat = {};
  @override
void initState() {
  super.initState();
  muatFavorit();
}
 
 
Future<void> muatFavorit() async {
  final prefs = await SharedPreferences.getInstance();

  final daftar = prefs.getStringList('surahFavorit') ?? [];
  final Map<String, int> penanda = {};

  final dataTersimpan = prefs.getString('daftar_surah');

final List<dynamic> semuaSurah = dataTersimpan == null
    ? dataSurah
    : jsonDecode(dataTersimpan) as List<dynamic>;

for (final surah in semuaSurah) {
    final nama = surah['nama'] as String;
    final nomor = prefs.getInt('penanda_$nama');

    if (nomor != null) {
      penanda[nama] = nomor;
    }
  }

  if (!mounted) return;

  setState(() {
    daftarFavorit = daftar;
    penandaAyat = penanda;
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Saya'),
      ),
     
 

body: ListView(
  children: [
    const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        '❤️ Surah Favorit',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    if (daftarFavorit.isEmpty)
      const ListTile(
        title: Text('Belum ada surah favorit.'),
      )
    else
      ...daftarFavorit.map((namaSurah) {
        return ListTile(
          leading: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          title: Text(namaSurah),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanBacaan(
                   namaSurah: namaSurah,
                  
                
                ),
              ),
            );
          },
        );
      }),

    const Divider(),

    const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        '🔖 Ayat Ditandai',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    if (penandaAyat.isEmpty)
      const ListTile(
        title: Text('Belum ada ayat yang ditandai.'),
      )
    else
      ...penandaAyat.entries.map((penanda) {
        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(penanda.key),
          subtitle: Text('Ayat ${penanda.value}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanBacaan(
                    namaSurah: penanda.key,
                    nomorAyatTujuan: penanda.value,

                ),
              ),
            );
          },
        );
      }),
  ],
),

     );
  }
}