import 'dart:async';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'data_surah.dart';
import 'api_quran.dart';
import 'data_quran_lokal.dart';

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
static const String teksBasmalah =
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

int? ayatTerakhir;


Map<String, dynamic>? dataSurahApi;
bool sedangMemuat = false;
String? pesanError;

bool sudahMenujuAyat = false;
final AudioPlayer audioPlayer = AudioPlayer();
String qariTerpilih = '05';
bool sedangAutoPlay = false;
int indeksAutoPlay = 0;
StreamSubscription<PlayerState>? listenerAudio;
List<Map<String, dynamic>> daftarAyat = [];


final Map<String, String> daftarQari = { 
  '05': 'Misyari Rasyid Al-Afasi',
  '03': 'Abdurrahman as-Sudais',
  '04': 'Ibrahim Al-Dossari',
  '02': 'Abdulmuhsin Al-Qasim',
  '06': 'Yasser Al-Dosari',

   };
final ItemScrollController itemScrollController =
    ItemScrollController();

final ItemPositionsListener itemPositionsListener =
    ItemPositionsListener.create();

 @override
void initState() {
  super.initState();

listenerAudio = audioPlayer.playerStateStream.listen((state) {
  if (state.processingState == ProcessingState.completed &&
      sedangAutoPlay) {
    indeksAutoPlay++;
    putarAyatBerikutnya();
  }
});

  muatPenandaAyat();
  muatDataSurahApi();
}

void menujuAyatTujuan(int jumlahAyat) {
  final nomor = widget.nomorAyatTujuan;

  if (nomor == null || nomor < 1 || nomor > jumlahAyat) {
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || sudahMenujuAyat) return;

    if (!itemScrollController.isAttached) {
      menujuAyatTujuan(jumlahAyat);
      return;
    }

    sudahMenujuAyat = true;

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

  final prefs = await SharedPreferences.getInstance();

  // 1. Periksa cache SharedPreferences.
  final dataTersimpan =
      prefs.getString('data_surah_$nomorSurah');

  if (dataTersimpan != null) {
    try {
      final dataCache =
          jsonDecode(dataTersimpan) as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        dataSurahApi = dataCache;
        sedangMemuat = false;
      });
    } catch (e) {
      debugPrint('Cache tidak dapat dibaca: $e');
    }
  }

  // 2. Jika cache belum tersedia, gunakan JSON bawaan.
  if (dataSurahApi == null) {
    try {
      final dataLokal =
          await ambilDataSurahLokal(nomorSurah);

      if (!mounted) return;

      setState(() {
        dataSurahApi = dataLokal;
        sedangMemuat = false;
      });
    } catch (e) {
      debugPrint('Data lokal tidak dapat dibaca: $e');
    }
  }

  // 3. Coba perbarui data melalui API.
  try {
    final hasil = await ambilDataSurah(nomorSurah);

    await prefs.setString(
      'data_surah_$nomorSurah',
      jsonEncode(hasil),
    );

    if (!mounted) return;

    setState(() {
      dataSurahApi = hasil;
      sedangMemuat = false;
      pesanError = null;
    });
  } catch (e) {
    if (!mounted) return;

    // Jika semua sumber data gagal, tampilkan pesan error.
    if (dataSurahApi == null) {
      setState(() {
        pesanError = e.toString();
        sedangMemuat = false;
      });
    }
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

  Future<void> putarAudioAyat(
    Map<String, dynamic> ayat, {
    bool dariAutoPlay = false,
  }) async {
  if (!dariAutoPlay && sedangAutoPlay) {
    setState(() {
      sedangAutoPlay = false;
    });
  }
  final audio = ayat['audio'] as Map<String, dynamic>;
  final url = audio[qariTerpilih] as String;

  try {
    await audioPlayer.setUrl(url);
    await audioPlayer.play();
  } catch (e) {
    debugPrint('Gagal memutar audio: $e');
  }
}

Future<void> putarAyatBerikutnya() async {
  if (!sedangAutoPlay || !mounted) return;

  if (indeksAutoPlay >= daftarAyat.length) {
    setState(() {
      sedangAutoPlay = false;
      indeksAutoPlay = 0;
    });
    return;
  }

  final ayat = daftarAyat[indeksAutoPlay];
  await putarAudioAyat(ayat, dariAutoPlay: true);
}

  @override
  Widget build(BuildContext context) {
    // Memilih data ayat berdasarkan nama surah.
     if (dataSurahApi == null) {
       return Scaffold(
        appBar: AppBar(
  title: Text(widget.namaSurah),
  actions: [
    PopupMenuButton<String>(
      tooltip: 'Pilih qari',
      icon: const Icon(Icons.record_voice_over),
      onSelected: (kode) {
        setState(() {
          qariTerpilih = kode;
        });
      },
      itemBuilder: (context) {
        return daftarQari.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList();
      },
    ),
  ],
),
          body: Center(
         child: sedangMemuat
          ? const CircularProgressIndicator()
          : Text(
              pesanError ?? 'Data surah tidak tersedia.',
            ),
       ),
     );
    }
  
if (dataSurahApi != null) {

    final daftarAyatApi =
      dataSurahApi!['ayat'] as List<dynamic>;

  daftarAyat = daftarAyatApi.map((ayat) {
    return {
      'nomor': ayat['nomorAyat'],
      'arab': ayat['teksArab'],
      'terjemahan': ayat['teksIndonesia'],
      'audio': ayat['audio'],
      };
       }).toList();
     } else if (widget.namaSurah == 'Al-Baqarah') {
        daftarAyat = dataAyatBaqarah;
       } else {
       daftarAyat = dataAyatFatihah;
       }
      
        if (!sudahMenujuAyat &&
        widget.nomorAyatTujuan != null &&
       dataSurahApi != null) {
      menujuAyatTujuan(daftarAyat.length);
      }

       
    return Scaffold(
     appBar: AppBar(
      title: Text(widget.namaSurah),
       actions: [
  IconButton(
  tooltip: sedangAutoPlay ? 'Jeda Auto Play' : 'Mulai Auto Play',
  icon: Icon(
    sedangAutoPlay ? Icons.pause_circle : Icons.play_circle,
  ),
  onPressed: () async {
    if (sedangAutoPlay) {
      setState(() {
        sedangAutoPlay = false;
      });
      await audioPlayer.pause();
    } else {
      setState(() {
        sedangAutoPlay = true;
      });

      if (audioPlayer.processingState == ProcessingState.ready &&
          audioPlayer.position > Duration.zero) {
        await audioPlayer.play();
      } else {
        await putarAyatBerikutnya();
      }
    }
  },
),

    PopupMenuButton<String>(
      tooltip: 'Pilih qari',
      icon: const Icon(Icons.record_voice_over),
      onSelected: (kode) {
        setState(() {
          qariTerpilih = kode;
        });
      },
      itemBuilder: (context) => daftarQari.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              fontWeight: qariTerpilih == entry.key
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    ),
  ],
),
       
       body: Column(
        children: [
        
    Expanded(
      child: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        padding: const EdgeInsets.all(24),
         itemCount: daftarAyat.length +
         (widget.namaSurah != 'Al-Fatihah' &&
          widget.namaSurah != 'At-Taubah' ? 1 : 0),
        itemBuilder: (context, index) {
  final adaBasmalah =
      widget.namaSurah != 'Al-Fatihah' &&
      widget.namaSurah != 'At-Taubah';

    if (adaBasmalah && index == 0) {
     return Column(
      children: [
      Text(
        teksBasmalah,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 30),
      ),
      IconButton(
        icon: const Icon(Icons.play_circle_outline),
       onPressed: null,
        tooltip: 'Audio Basmalah belum tersedia',
      ),
      const SizedBox(height: 24),
    ],
  );
}

  final indeksAyat = adaBasmalah ? index - 1 : index;
  final ayat = daftarAyat[indeksAyat];

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
      icon: const Icon(Icons.play_circle_outline),
      onPressed: () {
        putarAudioAyat(ayat);
      },
      tooltip: 'Putar audio ayat',
    ),
    
    
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
          ),
        ],
      ),
    );
    }

        @override
           void dispose() {
           listenerAudio?.cancel();
           audioPlayer.dispose();
           super.dispose();
  }
}
