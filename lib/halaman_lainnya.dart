
import 'package:flutter/material.dart';

class HalamanLainnya extends StatelessWidget {
  const HalamanLainnya({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = [
      (
        Icons.settings_rounded,
        'Pengaturan Aplikasi',
        'Atur tampilan dan preferensi aplikasi',
      ),
      (
        Icons.record_voice_over_rounded,
        'Pilihan Qari',
        'Pilih suara qari favorit',
      ),
      (
        Icons.radio_button_checked_rounded,
        'Tasbih Digital',
        'Fitur dzikir dan penghitung tasbih',
      ),
      (
        Icons.info_outline_rounded,
        'Informasi Aplikasi',
        'Tentang Al-Qur’an Digital',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E5),
      appBar: AppBar(
        title: const Text('Lainnya'),
        backgroundColor: const Color(0xFF174B3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Tambahan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF174B3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan pengaturan dan fitur pendukung ibadah.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718078),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView.separated(
                itemCount: menu.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFFFFFCF5),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            const Color(0xFF174B3A).withValues(alpha: 0.09),
                        child: Icon(
                          menu[index].$1,
                          color: const Color(0xFF28634D),
                          size: 27,
                        ),
                      ),
                      title: Text(
                        menu[index].$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF263D32),
                        ),
                      ),
                      subtitle: Text(
                        menu[index].$3,
                        style: const TextStyle(
                          color: Color(0xFF718078),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Color(0xFFC5A45D),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
