import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_bacaan.dart';
import 'data_surah.dart';
import 'halaman_bookmark.dart';
import 'api_quran.dart';
import 'data_quran_lokal.dart';
import 'dart:convert';

import 'halaman_jadwal_sholat.dart';
import 'halaman_belajar.dart';
import 'halaman_lainnya.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Al-Qur'an Digital",
     theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1B6B50),
  ),
  useMaterial3: true,
),
      home: const HalamanNavigasi(),
    );
  }
}


class HalamanNavigasi extends StatefulWidget {
  const HalamanNavigasi({super.key});

  @override
  State<HalamanNavigasi> createState() => _HalamanNavigasiState();
}

class _HalamanNavigasiState extends State<HalamanNavigasi> {
  int halamanAktif = 0;

  final List<Widget> daftarHalaman = [
    const MyHomePage(title: "Al-Qur'an Digital"),
    const HalamanJadwalSholat(),
    const HalamanBelajar(),
    const HalamanLainnya(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: halamanAktif,
        children: daftarHalaman,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: halamanAktif,
        onTap: (index) {
          setState(() {
            halamanAktif = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B5E20),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Al-Qur'an",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Jadwal Sholat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Belajar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Lainnya",
          ),
        ],
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
Future<void> simpanSurahTerakhir(String namaSurah) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('surahTerakhir', namaSurah);
}
Future<List<String>> muatSurahFavorit() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('surahFavorit') ?? [];
}


Future<void> muatFavorit() async {
  final daftar = await muatSurahFavorit();

  if (!mounted) return;

  setState(() {
    surahFavorit = daftar.toSet();
  });
}

Future<void> ubahFavorit(String namaSurah) async {
  setState(() {
    if (surahFavorit.contains(namaSurah)) {
      surahFavorit.remove(namaSurah);
    } else {
      surahFavorit.add(namaSurah);
    }
  });

  await simpanSurahFavorit(surahFavorit.toList());
}

Future<void> simpanSurahFavorit(List<String> daftarFavorit) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('surahFavorit', daftarFavorit);
}



Future<void> muatSurahTerakhir() async {
  final prefs = await SharedPreferences.getInstance();
  final nama = prefs.getString('surahTerakhir');

  if (!mounted) return;

  setState(() {
    surahTerakhir = nama;
  });
}

  String? surahTerakhir;
  Set<String> surahFavorit = {};
  final TextEditingController pencarianController =
    TextEditingController();

String kataPencarian = '';
  
   List<Map<String, dynamic>> daftarSurah = dataSurah;

   int progresUnduh = 0;
   bool sedangMengunduh = false;


Future<void> muatDaftarSurah() async {
  try {
    // Muat 114 surah dari JSON lokal.
    final dataLokal = await ambilDaftarSurahLokal();

    if (!mounted) return;

    setState(() {
      daftarSurah = dataLokal;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'daftar_surah',
      jsonEncode(dataLokal),
    );

    // Perbarui data melalui API jika internet tersedia.
    try {
      final hasil = await ambilDaftarSurah();

      await prefs.setString(
        'daftar_surah',
        jsonEncode(hasil),
      );

      if (!mounted) return;

      setState(() {
        daftarSurah = hasil;
      });
    } catch (e) {
      debugPrint('Gagal memperbarui daftar surah dari API: $e');
    }
  } catch (e) {
    debugPrint('Gagal memuat daftar surah lokal: $e');
  }
}

Future<void> simpanDataSurahOffline(
  int nomorSurah,
  Map<String, dynamic> data,
) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'data_surah_$nomorSurah',
    jsonEncode(data),
  );
}

Future<void> mulaiUnduhSemuaSurah() async {
  setState(() {
    sedangMengunduh = true;
    progresUnduh = 0;
  });

  try {
    await unduhSemuaSurah(
      simpanData: simpanDataSurahOffline,
      saatProgres: (selesai) {
        if (!mounted) return;

        setState(() {
          progresUnduh = selesai;
        });
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua 114 surah berhasil disimpan untuk offline.'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unduhan gagal: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        sedangMengunduh = false;
      });
    }
  }
}



@override
void initState() {
  super.initState();
  muatSurahTerakhir();
   muatFavorit();
   muatDaftarSurah();
}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
   
return Scaffold(
 
  appBar: AppBar(
    backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      elevation: 2,
      title: Text(
       widget.title,
        style: const TextStyle(
       fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.download),
      tooltip: 'Unduh semua surah untuk offline',
      onPressed: sedangMengunduh ? null : mulaiUnduhSemuaSurah,
    ),
    IconButton(
      icon: const Icon(Icons.bookmarks_outlined),
      tooltip: 'Bookmark Saya',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HalamanBookmark(),
          ),
        );
      },
    ),
  ],
),

 // than having to individually change instances of widgets.
  
      body: SingleChildScrollView(
       padding: const EdgeInsets.all(16),
       child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,

     children: [
      
  
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF1B5E20),
        Color(0xFF388E3C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withValues(alpha: 0.18),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assalamu'alaikum",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Selamat datang di Al-Qur'an Digital",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Temukan dan baca surah Al-Qur'an",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      const Icon(
        Icons.menu_book_rounded,
        size: 55,
        color: Colors.white70,
      ),
    ],
  ),
),

            
Padding(
  padding: const EdgeInsets.symmetric(vertical: 16),
  child: TextField(
    controller: pencarianController,
    decoration: InputDecoration(
      hintText: 'Cari nama surah...',
      prefixIcon: const Icon(
        Icons.search,
        color: Color(0xFF2E7D32),
      ),
      filled: true,
      fillColor: const Color(0xFFF0F7F1),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD5E8D7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 1.5,
        ),
      ),
    ),
    onChanged: (value) {
      setState(() {
        kataPencarian = value;
      });
    },
  ),
),


                  if (sedangMengunduh) ...[
                  Padding(
                  padding: const EdgeInsets.all(12),
                   child: Column(
                  children: [
                   LinearProgressIndicator(
                  value: progresUnduh / 114,
                   ),
                   const SizedBox(height: 8),
                  Text('Mengunduh surah: $progresUnduh dari 114'),
                           ],
                         ),
                        ),
                       ],
                   
                   const SizedBox(height: 20),
                 Padding(
                   padding: const EdgeInsets.all(12),
                    child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                    'Bacaan Terakhir',
                    style: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,

                    ),
                   ),
                  ),
                 ),
              Card(
               child: ListTile(
               isThreeLine: true,
              onTap: () async {
final nama = surahTerakhir!;

setState(() {
surahTerakhir = nama;
});

await simpanSurahTerakhir(nama);

if (!context.mounted) return;

Navigator.push(
context,
MaterialPageRoute(
builder: (context) => HalamanBacaan(
namaSurah: nama,
nomorSurah: daftarSurah.firstWhere(
  (item) => item['nama'] == nama,
)['nomor'] as int,
),
),
);
},
          leading: const Icon(Icons.menu_book),
           title: Text(surahTerakhir ?? 'Belum ada bacaan'),
           subtitle: Text(
            surahTerakhir == null
          ? 'Surah yang terakhir kamu buka akan muncul di sini.'
          : 'Ketuk untuk membaca kembali',
    ),
    trailing: const Icon(Icons.chevron_right),
  ),
),


const SizedBox(height: 12),


LayoutBuilder(
  builder: (context, constraints) {
    final surahTersaring = daftarSurah.where((surah) {
      return surah['nama']
          .toLowerCase()
          .contains(kataPencarian.toLowerCase());
    }).toList();

    final jumlahKolom = constraints.maxWidth >= 900
        ? 3
        : constraints.maxWidth >= 600
            ? 2
            : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surahTersaring.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
       crossAxisCount: jumlahKolom,
       mainAxisExtent: 145,
       crossAxisSpacing: 10,
       mainAxisSpacing: 10,
        ),
      itemBuilder: (context, index) {
        final surah = surahTersaring[index];

      return Card(
  elevation: 2,
  color: const Color(0xFFF0F7F1),
  margin: const EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 5,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: BorderSide(
      color: Colors.green.shade100,
      width: 0.8,
    ),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () async {
      final nama = surah['nama'] as String;

      setState(() {
        surahTerakhir = nama;
      });

      await simpanSurahTerakhir(nama);

      if (!context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanBacaan(
            namaSurah: nama,
            nomorSurah: surah['nomor'] as int,
          ),
        ),
      );

      await muatSurahTerakhir();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          CircleAvatar(
          radius: 25,
           backgroundColor: const Color(0xFFA7F3D0),
           foregroundColor: const Color(0xFF185C46),
           child: Text(
          "${surah['nomor']}",
          style: const TextStyle(
         fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah['nama'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                   fontSize: 17,
                   fontWeight: FontWeight.w600,
                    color: Color(0xFF263D32),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  surah['namaArab'] ?? '',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                   fontSize: 21,
                    fontWeight: FontWeight.bold,
                     color: Color(0xFF185C46),
                     ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${surah['jumlahAyat']} ayat",
                   style: const TextStyle(
                     fontSize: 14,
                     color: Color(0xFF718078),
                      ),
                     ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              surahFavorit.contains(surah['nama'])
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              ubahFavorit(surah['nama'] as String);
            },
            tooltip: 'Surah favorit',
          ),
        ],
      ),
    ),  ),
      );
      },
    );
  },
),
      ]),
    ));
  }
}