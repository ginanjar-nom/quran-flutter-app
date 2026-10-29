import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_bacaan.dart';
import 'data_surah.dart';
import 'halaman_bookmark.dart';
import 'api_quran.dart';
import 'dart:convert';


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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const MyHomePage(title: "Al-Qur'an Digital"),
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
  final prefs = await SharedPreferences.getInstance();

  // Muat daftar yang tersimpan agar bisa digunakan offline.
  final dataTersimpan = prefs.getString('daftar_surah');

  if (dataTersimpan != null) {
    final dataLokal =
        (jsonDecode(dataTersimpan) as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    if (!mounted) return;

    setState(() {
      daftarSurah = dataLokal;
    });
  }
    
  // Perbarui daftar jika internet tersedia.
  try {
    final hasil = await ambilDaftarSurah();

    await prefs.setString('daftar_surah', jsonEncode(hasil));

    if (!mounted) return;

    setState(() {
      daftarSurah = hasil;
    });
  } catch (e) {
    debugPrint('Menggunakan daftar surah tersimpan: $e');
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
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Text(widget.title),
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
            const Text("Assalamu'alaikum",style:TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
            const Text("Selamat datang di Al-Qur'an Digital"),
            const Text("Temukan dan baca surah Al-Qur'an"),
            TextField(
               controller: pencarianController,
               decoration: const InputDecoration(
               hintText: 'Cari nama surah...',
               prefixIcon: Icon(Icons.search),
               border: OutlineInputBorder(),
                         ),
               onChanged: (value) {
               setState(() {
              kataPencarian = value;
                     });
                   },
                  ) 
                   ,
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


...daftarSurah
    .where((surah) {
      return surah['nama']
          .toLowerCase()
          .contains(kataPencarian.toLowerCase());
               })
     .map((surah) {

  return Card(
    child: ListTile(
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
      leading: CircleAvatar(child: Text("${surah['nomor']}")),
      title: Text(surah['nama']),
      subtitle: Text("${surah['jumlahAyat']} ayat"),
      
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    
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

    const Icon(Icons.chevron_right),
  ],
),

    ),
  );
})],
        ),
      ),
    );
  }
}