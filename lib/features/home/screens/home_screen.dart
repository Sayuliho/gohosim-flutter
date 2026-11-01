import 'dart:async';
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
            // Hero banner — carousel auto-rotate
            const _HeroBannerCarousel(),

            const SizedBox(height: 10),

            // Search card — slim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Traveler! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Mau kemana hari ini? Cari paket eSIM terbaik',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.push('/packages'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppTheme.textGrey, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Cari negara tujuan...',
                                style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Banner HP support eSIM — slim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => context.push('/packages'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'HP kamu support eSIM?',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(
                        'Cek →',
                        style: TextStyle(
                          color: AppTheme.cta,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

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

// ── Banner carousel ──────────────────────────────────────────────────────────

class _BannerSlide {
  final List<Color> colors;
  final String emoji;
  final String title;
  final String subtitle;
  final String cta;

  const _BannerSlide({
    required this.colors,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
  });
}

const _bannerSlides = [
  _BannerSlide(
    colors: [Color(0xFF006D6A), Color(0xFF00B4A8)],
    emoji: '✈️',
    title: 'Cari jalan.\nBagikan cerita.',
    subtitle: 'Temani perjalananmu dengan GohoSIM.',
    cta: 'Mulai sekarang →',
  ),
  _BannerSlide(
    colors: [Color(0xFF0057FF), Color(0xFF3B82F6)],
    emoji: '🌏',
    title: 'Internet\n150+ Negara',
    subtitle: 'Langsung aktif tanpa ganti kartu SIM.',
    cta: 'Cek paket →',
  ),
  _BannerSlide(
    colors: [Color(0xFF1a1a6e), Color(0xFFb21f1f)],
    emoji: '🇯🇵',
    title: 'eSIM Jepang\nmulai Rp 45.000',
    subtitle: 'Data 1–5GB, aktivasi instan.',
    cta: 'Beli sekarang →',
  ),
];

class _HeroBannerCarousel extends StatefulWidget {
  const _HeroBannerCarousel();

  @override
  State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
  final PageController _ctrl = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _bannerSlides.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _bannerSlides.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (ctx, i) {
              final s = _bannerSlides[i];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: s.colors,
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
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Konten
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 90, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.subtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.cta,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Emoji dekoratif
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(s.emoji, style: const TextStyle(fontSize: 54)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Dots indicator
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerSlides.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Country card ─────────────────────────────────────────────────────────────

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
