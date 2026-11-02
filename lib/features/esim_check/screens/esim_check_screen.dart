import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/app_theme.dart';

class EsimCheckScreen extends StatelessWidget {
  const EsimCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cek Kompatibilitas eSIM',
          style: TextStyle(color: AppTheme.textDark, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF00A8B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📱', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  const Text(
                    'HP Kamu Support eSIM?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cek dengan salah satu cara di bawah ini',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cara cek
            const Text(
              'Cara Cek di HP Kamu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),

            _StepCard(
              icon: '🤖',
              title: 'Android',
              steps: const [
                'Buka Pengaturan (Settings)',
                'Pilih Koneksi → Manajer SIM',
                'Jika ada opsi "Tambah eSIM" atau "eSIM", HP kamu support eSIM ✅',
              ],
            ),
            const SizedBox(height: 12),
            _StepCard(
              icon: '🍎',
              title: 'iPhone',
              steps: const [
                'Buka Pengaturan (Settings)',
                'Pilih Seluler / Cellular',
                'Jika ada opsi "Tambahkan eSIM", iPhone kamu support eSIM ✅',
              ],
            ),
            const SizedBox(height: 24),

            // HP yang support
            const Text(
              'HP Populer yang Support eSIM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),

            _BrandSection(brand: 'Samsung', models: const [
              'Galaxy S21, S22, S23, S24 (semua varian)',
              'Galaxy Z Fold 3/4/5/6',
              'Galaxy Z Flip 3/4/5/6',
              'Galaxy A54, A55',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'iPhone', models: const [
              'iPhone XS, XS Max, XR ke atas',
              'iPhone 11, 12, 13, 14, 15, 16 (semua varian)',
              'iPhone SE (2020, 2022)',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'Google Pixel', models: const [
              'Pixel 3 ke atas',
              'Pixel 6, 7, 8, 9 (semua varian)',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'Oppo / OnePlus', models: const [
              'Find X3 Pro, Find X5, Find X6, Find X7',
              'OnePlus 11, 12',
            ]),
            const SizedBox(height: 24),

            // Info tidak support
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HP entry-level atau varian tertentu (misal: Samsung A14, Xiaomi Redmi) umumnya belum support eSIM. Cek spesifikasi resmi HP kamu jika tidak yakin.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> steps;

  const _StepCard({required this.icon, required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
          ]),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  final String brand;
  final List<String> models;

  const _BrandSection({required this.brand, required this.models});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
          const SizedBox(height: 6),
          ...models.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                Expanded(child: Text(m, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
