
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:adhan/adhan.dart';

class HalamanJadwalSholat extends StatefulWidget {
  const HalamanJadwalSholat({super.key});

  @override
  State<HalamanJadwalSholat> createState() =>
      _HalamanJadwalSholatState();
}

class _HalamanJadwalSholatState
    extends State<HalamanJadwalSholat> {
  bool sedangMemproses = false;
  String statusLokasi = 'Lokasi belum diatur';
  LatLng? koordinatPengguna;
  PrayerTimes? jadwalSholat;

  Future<void> aturLokasi() async {
    final disetujui = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi'),
        content: const Text(
          'Aplikasi memerlukan lokasi Anda untuk '
          'menampilkan jadwal sholat sesuai daerah. '
          'Apakah Anda bersedia memberikan izin lokasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );

    if (disetujui != true || !mounted) return;

    setState(() {
      sedangMemproses = true;
    });

    try {
      final layananAktif =
          await Geolocator.isLocationServiceEnabled();

      if (!layananAktif) {
        setState(() {
          statusLokasi = 'Layanan lokasi belum aktif';
        });
        return;
      }

      LocationPermission izin =
          await Geolocator.checkPermission();

      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }

      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        setState(() {
          statusLokasi = 'Izin lokasi belum diberikan';
        });
        return;
      }

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      if (!mounted) return;

      setState(() {
  koordinatPengguna = LatLng(
    posisi.latitude,
    posisi.longitude,
  );

  statusLokasi =
      'Lokasi Anda Saat Ini';
});
  hitungJadwalSholat();
  
    } catch (e) {
      setState(() {
        statusLokasi = 'Gagal memperoleh lokasi';
      });
    } finally {
      if (mounted) {
        setState(() {
          sedangMemproses = false;
        });
      }
    }
  }

    void hitungJadwalSholat() {
    if (koordinatPengguna == null) return;

    final koordinat = Coordinates(
      koordinatPengguna!.latitude,
      koordinatPengguna!.longitude,
    );

    final tanggal = DateComponents.from(DateTime.now());

    final parameter =
        CalculationMethod.muslim_world_league.getParameters()
          ..madhab = Madhab.shafi;

    final hasil = PrayerTimes(
      koordinat,
      tanggal,
      parameter,
    );

    setState(() {
      jadwalSholat = hasil;
    });
  }

 String formatWaktu(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:'
       '${waktu.minute.toString().padLeft(2, '0')}';
}


Widget _barisWaktuSholat(String nama, DateTime waktu) {
  IconData ikon;

  switch (nama) {
    case 'Subuh':
      ikon = Icons.nightlight_round;
      break;
    case 'Zuhur':
      ikon = Icons.wb_sunny;
      break;
    case 'Asar':
      ikon = Icons.wb_cloudy;
      break;
    case 'Magrib':
      ikon = Icons.wb_twilight;
      break;
    default:
      ikon = Icons.nights_stay;
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 13,
    ),
    decoration: BoxDecoration(
      color: const Color(0xE6F5EBDD),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE5C47A),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B4939),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            ikon,
            color: const Color(0xFFE5C47A),
            size: 23,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            nama,
            style: const TextStyle(
              color: Color(0xFF173B30),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          formatWaktu(waktu),
          style: const TextStyle(
            color: Color(0xFF173B30),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}


  
@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: const Color(0xFF173B30),
    appBar: AppBar(
      title: const Text(
        'Jadwal Sholat',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/latar_jadwal_sholat.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0x660B2D25),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mosque,
                  size: 55,
                  color: Color(0xFFE5C47A),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Jadwal Sholat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFF3D6),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  statusLokasi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),

                // Kartu peta lokasi
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: const Color(0xE6173B30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5C47A),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: koordinatPengguna == null
                      ? const Center(
                          child: Text(
                            'Peta akan tampil setelah lokasi diatur',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : FlutterMap(
                          options: MapOptions(
                            initialCenter: koordinatPengguna!,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.flutter_firstaplication',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: koordinatPengguna!,
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 22),

                if (jadwalSholat != null) ...[
                  const Text(
                    'Jadwal Sholat Hari Ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFF3D6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _barisWaktuSholat('Subuh', jadwalSholat!.fajr),
                  _barisWaktuSholat('Zuhur', jadwalSholat!.dhuhr),
                  _barisWaktuSholat('Asar', jadwalSholat!.asr),
                  _barisWaktuSholat('Magrib', jadwalSholat!.maghrib),
                  _barisWaktuSholat('Isya', jadwalSholat!.isha),
                ],

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: sedangMemproses ? null : aturLokasi,
                  icon: const Icon(Icons.location_on),
                  label: Text(
                    sedangMemproses ? 'Memproses...' : 'Atur Lokasi',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5C47A),
                    foregroundColor: const Color(0xFF173B30),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}

