
import 'package:flutter/material.dart';

class HalamanLainnya extends StatelessWidget {
  const HalamanLainnya({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lainnya'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 70,
              color: Color(0xFF1B5E20),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Lainnya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur tambahan akan tersedia di sini.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
