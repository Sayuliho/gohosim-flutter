import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../packages/screens/country_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sim_card, size: 20),
            const SizedBox(width: 8),
            const Text('GohoSIM'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF2E6DA4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mau traveling ke mana?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih negara & beli eSIM langsung aktif',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  GestureDetector(
                    onTap: () => context.push('/packages'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppTheme.textGrey),
                          SizedBox(width: 12),
                          Text(
                            'Cari negara tujuan...',
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick pick — destinasi populer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Destinasi Populer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CountryChip(code: 'JP', name: 'Jepang', flag: '🇯🇵'),
                  _CountryChip(code: 'KR', name: 'Korea', flag: '🇰🇷'),
                  _CountryChip(code: 'MY', name: 'Malaysia', flag: '🇲🇾'),
                  _CountryChip(code: 'SG', name: 'Singapura', flag: '🇸🇬'),
                  _CountryChip(code: 'TH', name: 'Thailand', flag: '🇹🇭'),
                  _CountryChip(code: 'SA', name: 'Arab Saudi', flag: '🇸🇦'),
                  _CountryChip(code: 'TR', name: 'Turki', flag: '🇹🇷'),
                  _CountryChip(code: 'GB', name: 'UK', flag: '🇬🇧'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // My eSIM shortcut
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sim_card_outlined, color: AppTheme.accent),
                  ),
                  title: const Text(
                    'eSIM Saya',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Lihat eSIM aktif & histori pembelian'),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                  onTap: () => context.push('/my-esims'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFFEFF6FF),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Cara pakai GohoSIM',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoStep(num: '1', text: 'Pilih negara & paket eSIM'),
                      _InfoStep(num: '2', text: 'Bayar via transfer/QRIS'),
                      _InfoStep(num: '3', text: 'Scan QR code di HP kamu'),
                      _InfoStep(num: '4', text: 'Internet langsung aktif saat tiba'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.push('/my-esims');
          if (i == 2) context.push('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.sim_card_outlined), selectedIcon: Icon(Icons.sim_card), label: 'eSIM Saya'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String code;
  final String name;
  final String flag;

  const _CountryChip({required this.code, required this.name, required this.flag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/packages?country=$code&name=${Uri.encodeComponent(name)}'),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  final String num;
  final String text;
  const _InfoStep({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            child: Center(
              child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
