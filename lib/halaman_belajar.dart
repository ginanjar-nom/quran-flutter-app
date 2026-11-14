
import 'package:flutter/material.dart';

class HalamanBelajar extends StatelessWidget {
  const HalamanBelajar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belajar'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 70,
              color: Color(0xFF1B5E20),
            ),
            SizedBox(height: 16),
            Text(
              'Belajar Al-Qur’an',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur pembelajaran akan segera tersedia.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
