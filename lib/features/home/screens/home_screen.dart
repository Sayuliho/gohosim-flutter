import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

            // Banner HP support eSIM — auto-detect
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _EsimBanner(),
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
        backgroundColor: const Color(0xFFE8F4F5),
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

// ── eSIM Banner (auto-detect) ─────────────────────────────────────────────────

class _EsimBanner extends StatefulWidget {
  const _EsimBanner();
  @override
  State<_EsimBanner> createState() => _EsimBannerState();
}

class _EsimBannerState extends State<_EsimBanner> {
  static const _ch = MethodChannel('com.gohotravel.gohosim/esim');
  // null = sedang cek, true = support, false = tidak support
  bool? _supported;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    try {
      final r = await _ch.invokeMapMethod<String, bool>('checkEsimSupport');
      final api = r?['apiSupported'] ?? false;
      final hw  = r?['hasHardware']  ?? false;
      final en  = r?['isEnabled']    ?? false;
      if (mounted) setState(() => _supported = api && hw && en);
    } catch (_) {
      if (mounted) setState(() => _supported = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sedang mendeteksi
    if (_supported == null) {
      return GestureDetector(
        onTap: () => context.push('/esim-check'),
        child: _bannerShell(
          color: const Color(0xFFF3F4F6),
          border: const Color(0xFFD1D5DB),
          icon: '📱',
          label: 'Mengecek kompatibilitas eSIM...',
          labelColor: const Color(0xFF6B7280),
          trailing: const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
    }

    // Support eSIM
    if (_supported == true) {
      return GestureDetector(
        onTap: () => context.push('/esim-check'),
        child: _bannerShell(
          color: const Color(0xFFDCFCE7),
          border: const Color(0xFF86EFAC),
          icon: '✅',
          label: 'HP kamu support eSIM',
          labelColor: const Color(0xFF166534),
          trailing: const Text('Detail →', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      );
    }

    // Tidak / tidak pasti
    return GestureDetector(
      onTap: () => context.push('/esim-check'),
      child: _bannerShell(
        color: const Color(0xFFFFF3CD),
        border: const Color(0xFFFFE082),
        icon: '📱',
        label: 'HP kamu support eSIM?',
        labelColor: const Color(0xFF856404),
        trailing: const Text('Cek →', style: TextStyle(color: AppTheme.cta, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _bannerShell({
    required Color color, required Color border,
    required String icon, required String label, required Color labelColor,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.w600, fontSize: 12))),
        trailing,
      ]),
    );
  }
}

// ── Banner carousel ──────────────────────────────────────────────────────────

class _BannerSlide {
  final String imagePath;
  const _BannerSlide({required this.imagePath});
}

const _bannerSlides = [
  _BannerSlide(imagePath: 'assets/banners/ad-airport.jpg'),
  _BannerSlide(imagePath: 'assets/banners/ad-japan.jpg'),
  _BannerSlide(imagePath: 'assets/banners/ad-china.jpg'),
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
          height: 172,
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
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  s.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
