import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'goho',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'SIM',
                style: TextStyle(
                  color: AppTheme.cta,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.textDark),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner foto
            _HeroBanner(),

            const SizedBox(height: 16),

            // Search card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Traveler! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mau kemana hari ini? Cari paket eSIM terbaik',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.push('/packages'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppTheme.textGrey),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Cari negara tujuan...',
                                style: TextStyle(color: AppTheme.textGrey, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Banner HP support eSIM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => context.push('/packages'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'HP kamu support eSIM?',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Text(
                        'Cek →',
                        style: TextStyle(
                          color: AppTheme.cta,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Destinasi populer header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Destinasi Populer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Country list dengan harga
            _CountryCard(flag: '🇯🇵', name: 'Jepang', countryCode: 'JP', packageCount: '182 paket', startPrice: 'Rp 12.600'),
            _CountryCard(flag: '🇰🇷', name: 'Korea Selatan', countryCode: 'KR', packageCount: '113 paket', startPrice: 'Rp 10.300'),
            _CountryCard(flag: '🇲🇾', name: 'Malaysia', countryCode: 'MY', packageCount: '96 paket', startPrice: 'Rp 8.500'),
            _CountryCard(flag: '🇸🇬', name: 'Singapura', countryCode: 'SG', packageCount: '84 paket', startPrice: 'Rp 9.200'),
            _CountryCard(flag: '🇹🇭', name: 'Thailand', countryCode: 'TH', packageCount: '78 paket', startPrice: 'Rp 7.800'),
            _CountryCard(flag: '🇸🇦', name: 'Arab Saudi', countryCode: 'SA', packageCount: '45 paket', startPrice: 'Rp 15.000'),
            _CountryCard(flag: '🇹🇷', name: 'Turki', countryCode: 'TR', packageCount: '52 paket', startPrice: 'Rp 11.500'),

            // Lihat semua
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: OutlinedButton(
                onPressed: () => context.push('/packages'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lihat Semua Negara', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        onDestinationSelected: (i) {
          if (i == 1) context.push('/packages');
          if (i == 2) context.push('/my-esims');
          if (i == 3) context.push('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppTheme.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.language_outlined), selectedIcon: Icon(Icons.language, color: AppTheme.primary), label: 'Paket'),
          NavigationDestination(icon: Icon(Icons.sim_card_outlined), selectedIcon: Icon(Icons.sim_card, color: AppTheme.primary), label: 'My eSIM'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppTheme.primary), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF006D6A), Color(0xFF00B4A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Konten
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'gohoSIM',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cari jalan.\nBagikan cerita.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Temani perjalananmu dengan GohoSIM.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Icon pesawat dekoratif
          const Positioned(
            right: 24,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text('✈️', style: TextStyle(fontSize: 60)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final String flag;
  final String name;
  final String countryCode;
  final String packageCount;
  final String startPrice;

  const _CountryCard({
    required this.flag,
    required this.name,
    required this.countryCode,
    required this.packageCount,
    required this.startPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/packages?country=$countryCode&name=${Uri.encodeComponent(name)}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: const Border(
            left: BorderSide(color: AppTheme.primary, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    packageCount,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'mulai',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
                Text(
                  startPrice,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textGrey, size: 20),
          ],
        ),
      ),
    );
  }
}
