import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'data_surah.dart';
import 'api_quran.dart';

class HalamanBacaan extends StatefulWidget {
  final String namaSurah;
  final int? nomorSurah;
 final int? nomorAyatTujuan;

  const HalamanBacaan({
    super.key,
    required this.namaSurah,
     this.nomorSurah,
     this.nomorAyatTujuan,
  });

  
  @override
  State<HalamanBacaan> createState() => _HalamanBacaanState();
}

class _HalamanBacaanState extends State<HalamanBacaan> {
int? ayatTerakhir;

Map<String, dynamic>? dataSurahApi;
bool sedangMemuat = false;
String? pesanError;

bool sudahMenujuAyat = false;

final ItemScrollController itemScrollController =
    ItemScrollController();

final ItemPositionsListener itemPositionsListener =
    ItemPositionsListener.create();

 @override

 @override
void initState() {
  super.initState();
  muatPenandaAyat();
  muatDataSurahApi();
}

void menujuAyatTujuan(int jumlahAyat) {
  final nomor = widget.nomorAyatTujuan;

  if (nomor == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    if (!itemScrollController.isAttached) return;

    if (nomor < 1 || nomor > jumlahAyat) return;

    itemScrollController.scrollTo(
      index: nomor - 1,
      duration: const Duration(milliseconds: 500),
      alignment: 0.1,
    );
  });
}


Future<void> muatDataSurahApi() async {
  final nomorSurah = widget.nomorSurah ??
      dataSurah.firstWhere(
        (surah) => surah['nama'] == widget.namaSurah,
      )['nomor'] as int;

  setState(() {
    sedangMemuat = true;
    pesanError = null;
  });

  try {  
    final hasil = await ambilDataSurah(nomorSurah);

    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
     'data_surah_$nomorSurah',
     jsonEncode(hasil),
    );

   if (!mounted) return;
   
    setState(() {
      dataSurahApi = hasil;
      sedangMemuat = false;
    });
   } catch (e) {
    final prefs = await SharedPreferences.getInstance();

    final dataTersimpan =
        prefs.getString('data_surah_$nomorSurah');
        debugPrint('Cache surah $nomorSurah ditemukan: ${dataTersimpan != null}');
    if (!mounted) return;

    setState(() {
      if (dataTersimpan != null) {
        dataSurahApi =
            jsonDecode(dataTersimpan) as Map<String, dynamic>;
        pesanError = null;
      } else {
        pesanError = e.toString();
      }

      sedangMemuat = false;
    });
  }
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

if (dataSurahApi != null) {

    final daftarAyatApi =
      dataSurahApi!['ayat'] as List<dynamic>;

  daftarAyat = daftarAyatApi.map((ayat) {
    return {
      'nomor': ayat['nomorAyat'],
      'arab': ayat['teksArab'],
      'terjemahan': ayat['teksIndonesia'],
      };
       }).toList();
     } else if (widget.namaSurah == 'Al-Baqarah') {
        daftarAyat = dataAyatBaqarah;
       } else {
       daftarAyat = dataAyatFatihah;
       
       if (!sudahMenujuAyat &&
    widget.nomorAyatTujuan != null &&
    (widget.namaSurah != 'Al-Baqarah' ||
        dataSurahApi != null)) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || sudahMenujuAyat) return;

    sudahMenujuAyat = true;
    menujuAyatTujuan(daftarAyat.length);
    });
          }}

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaSurah),
      ),
       
       body: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        padding: const EdgeInsets.all(24),
       itemCount: daftarAyat.length,
       itemBuilder: (context, index) {
       final ayat = daftarAyat[index];

     return Column(
        children: [
          Text(
           ayat['arab'],
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 30),
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
  },
),
);
}
}