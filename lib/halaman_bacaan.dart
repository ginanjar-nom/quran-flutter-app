import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_surah.dart';

class HalamanBacaan extends StatefulWidget {
  final String namaSurah;
 final int? nomorAyatTujuan;

  const HalamanBacaan({
    super.key,
    required this.namaSurah,
     this.nomorAyatTujuan,
  });

  
  @override
  State<HalamanBacaan> createState() => _HalamanBacaanState();
}

class _HalamanBacaanState extends State<HalamanBacaan> {
int? ayatTerakhir;
 final ScrollController scrollController = ScrollController();
 final Map<int, GlobalKey> kunciAyat = {};

 @override
void initState() {
  super.initState();
  muatPenandaAyat();
  menujuAyatTujuan();
}


void menujuAyatTujuan() {
  final nomor = widget.nomorAyatTujuan;

  if (nomor == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    final kunci = kunciAyat[nomor];
    final konteksAyat = kunci?.currentContext;

    if (konteksAyat == null) return;

    Scrollable.ensureVisible(
      konteksAyat,
      duration: const Duration(milliseconds: 500),
      alignment: 0.1,
    );
  });
}




Future<void> muatPenandaAyat() async {
  final prefs = await SharedPreferences.getInstance();
  final nomor = prefs.getInt('penanda_${widget.namaSurah}');

  if (!mounted) return;

  setState(() {
    ayatTerakhir = nomor;
  });
}




Future<void> simpanPenandaAyat(int nomorAyat) async {
  final prefs = await SharedPreferences.getInstance();

  final kunci = 'penanda_${widget.namaSurah}';

  if (ayatTerakhir == nomorAyat) {
    await prefs.remove(kunci);
  } else {
    await prefs.setInt(kunci, nomorAyat);
  }

  if (!mounted) return;

  setState(() {
    ayatTerakhir =
        ayatTerakhir == nomorAyat ? null : nomorAyat;
  });
}


  @override
  Widget build(BuildContext context) {
    // Memilih data ayat berdasarkan nama surah.
    final List<Map<String, dynamic>> daftarAyat;

    if (widget.namaSurah == 'Al-Baqarah') {
      daftarAyat = dataAyatBaqarah;
    } else {
      daftarAyat = dataAyatFatihah;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaSurah),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ...daftarAyat.map((ayat) {
               return Column(
                key: kunciAyat.putIfAbsent(
                  ayat['nomor'] as int,
                 () => GlobalKey(),
                       ),
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
                   
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('Ayat ${ayat['nomor']}'),
    IconButton(
      icon: Icon(
        ayatTerakhir == ayat['nomor']
            ? Icons.bookmark
            : Icons.bookmark_border,
      ),
      onPressed: () {
        simpanPenandaAyat(ayat['nomor'] as int);
      },
      tooltip: 'Tandai ayat terakhir',
    ),
  ],
),

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