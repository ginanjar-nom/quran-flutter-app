
import 'package:flutter/material.dart';

class HalamanJadwalSholat extends StatelessWidget {
  const HalamanJadwalSholat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mosque,
              size: 70,
              color: Color(0xFF1B5E20),
            ),
            SizedBox(height: 16),
            Text(
              'Jadwal Sholat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur jadwal sholat akan segera tersedia.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
