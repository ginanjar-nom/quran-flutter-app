
import 'package:flutter/material.dart';

class HalamanBelajar extends StatelessWidget {
  const HalamanBelajar({super.key});

  @override
  Widget build(BuildContext context) {
    final materi = [
      (Icons.mosque, 'Tata Cara Sholat'),
      (Icons.auto_stories, 'Rukun Islam dan Iman'),
      (Icons.volunteer_activism, 'Doa Harian'),
      (Icons.quiz, 'Kuis Islami'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belajar'),
        backgroundColor: const Color(0xFF174B3A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_masjid.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: const Color(0xFFF5F0E5).withValues(alpha: 0.48),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belajar Islam',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF174B3A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mari memperdalam ilmu dan pengetahuan Islam.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF263D32),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    itemCount: materi.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      return Card(
                        color: const Color(0xFFFFFCF5)
                            .withValues(alpha: 0.94),
                        elevation: 3,
                        shadowColor:
                            const Color(0xFF174B3A).withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: const Color(0xFFC5A45D)
                                .withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              materi[index].$1,
                              size: 42,
                              color: const Color(0xFF28634D),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                materi[index].$2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF263D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
