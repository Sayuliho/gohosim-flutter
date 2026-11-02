import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/packages_provider.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

// ── Supplier colors (sama dengan dashboard) ───────────────────────────────────
Color _supplierColor(String supplier) {
  switch (supplier) {
    case 'ir': return const Color(0xFF16A34A); // iRoamly — hijau
    case 'ec': return const Color(0xFF7C3AED); // eSIMCard — ungu
    default:   return const Color(0xFF0EA5E9); // eSIM Access (ea) — biru
  }
}

String _supplierLabel(String supplier) {
  switch (supplier) {
    case 'ir': return 'iRoamly';
    case 'ec': return 'eSIMCard';
    default:   return 'eSIM Access';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PackagesScreen extends StatefulWidget {
  final String countryCode;
  final String countryName;
  final String? countryFlag;

  const PackagesScreen({
    super.key,
    required this.countryCode,
    required this.countryName,
    this.countryFlag,
  });

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  // Coverage: 'single' | 'regional'
  String _coverage = 'single';
  // Type: 'all' | 'fixed' | 'unlimited'
  String _typeFilter = 'all';

  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackagesProvider>().fetchPackages(widget.countryCode);
    });
  }

  List<EsimPackage> _applyTypeFilter(List<EsimPackage> pkgs) {
    // Terapkan ALLOWED_DATA_GB filter (sama dengan PWA)
    final filtered = pkgs.where((p) => p.isAllowedSize).toList();
    if (_typeFilter == 'unlimited') return filtered.where((p) => p.unlimited).toList();
    if (_typeFilter == 'fixed')     return filtered.where((p) => !p.unlimited).toList();
    return filtered;
  }

  int _countType(String t, List<EsimPackage> all) {
    final filtered = all.where((p) => p.isAllowedSize).toList();
    if (t == 'unlimited') return filtered.where((p) => p.unlimited).length;
    if (t == 'fixed')     return filtered.where((p) => !p.unlimited).length;
    return filtered.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final singlePkgs = provider.packages;
    final regionalPkgs = provider.bundles;
    final flag = widget.countryFlag ?? '';

    // Paket yang ditampilkan sesuai tab Coverage
    final displayPkgs = _coverage == 'regional' ? regionalPkgs : singlePkgs;
    final isLoading = _coverage == 'regional' ? provider.loadingBundles : provider.loading;
    final hasError = _coverage == 'regional' ? provider.bundlesError != null : provider.error != null;
    final errorMsg = _coverage == 'regional' ? (provider.bundlesError ?? '') : (provider.error ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.countryName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Header teal ────────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              children: [
                // Flag + nama + jumlah
                Row(
                  children: [
                    if (flag.isNotEmpty) ...[
                      Text(flag, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.countryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isLoading && !hasError)
                            Text(
                              '${_applyTypeFilter(displayPkgs).length} pilihan paket',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Coverage toggle: Negara vs Regional ──
                _CoverageToggle(
                  value: _coverage,
                  singleCount: !provider.loading ? singlePkgs.where((p) => p.isAllowedSize).length : null,
                  regionalCount: !provider.loadingBundles ? regionalPkgs.length : null,
                  onChanged: (v) => setState(() {
                    _coverage = v;
                    _typeFilter = 'all'; // reset type filter saat ganti coverage
                  }),
                ),

                // ── Type filter: Fixed/Unlimited (hanya untuk tab single) ──
                if (_coverage == 'single') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterBtn(
                          emoji: '📦',
                          label: 'Fixed Data',
                          active: _typeFilter == 'fixed',
                          count: provider.loading ? null : _countType('fixed', singlePkgs),
                          onTap: () => setState(() => _typeFilter = _typeFilter == 'fixed' ? 'all' : 'fixed'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterBtn(
                          emoji: '♾️',
                          label: 'Unlimited/Hari',
                          active: _typeFilter == 'unlimited',
                          count: provider.loading ? null : _countType('unlimited', singlePkgs),
                          onTap: () => setState(() => _typeFilter = _typeFilter == 'unlimited' ? 'all' : 'unlimited'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Package list ────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : hasError
                    ? _ErrorState(
                        message: errorMsg,
                        onRetry: () => provider.fetchPackages(widget.countryCode),
                      )
                    : _applyTypeFilter(displayPkgs).isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                            itemCount: _applyTypeFilter(displayPkgs).length,
                            itemBuilder: (context, i) {
                              final pkg = _applyTypeFilter(displayPkgs)[i];
                              return _PackageCard(
                                pkg: pkg,
                                idr: _idr,
                                countryName: widget.countryName,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Coverage toggle (Negara / Regional) ──────────────────────────────────────

class _CoverageToggle extends StatelessWidget {
  final String value;
  final int? singleCount;
  final int? regionalCount;
  final ValueChanged<String> onChanged;

  const _CoverageToggle({
    required this.value,
    required this.singleCount,
    required this.regionalCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _Tab(
            label: '🌏 Negara Ini',
            count: singleCount,
            active: value == 'single',
            onTap: () => onChanged('single'),
            leftRadius: true,
          ),
          _Tab(
            label: '🗺️ Multi Negara',
            count: regionalCount,
            active: value == 'regional',
            onTap: () => onChanged('regional'),
            rightRadius: true,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int? count;
  final bool active;
  final bool leftRadius;
  final bool rightRadius;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.leftRadius = false,
    this.rightRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: leftRadius ? const Radius.circular(22) : Radius.zero,
              right: rightRadius ? const Radius.circular(22) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppTheme.primary : Colors.white,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.primary.withOpacity(0.12)
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: active ? AppTheme.primary : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter button (Fixed / Unlimited) ────────────────────────────────────────

class _FilterBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;
  final int? count;
  final VoidCallback onTap;

  const _FilterBtn({
    required this.emoji,
    required this.label,
    required this.active,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? Colors.white : Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppTheme.primary : Colors.white,
                ),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.primary.withOpacity(0.12)
                      : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: active ? AppTheme.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Package card (compact/slim) ───────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final EsimPackage pkg;
  final NumberFormat idr;
  final String countryName;

  const _PackageCard({
    required this.pkg,
    required this.idr,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    final supplierColor = _supplierColor(pkg.supplier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/package-detail', extra: {
            'package': pkg,
            'countryName': countryName,
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Baris 1: Data badge + premium + harga ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: pkg.unlimited
                            ? AppTheme.accent.withOpacity(0.1)
                            : AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: pkg.unlimited
                              ? AppTheme.accent.withOpacity(0.35)
                              : AppTheme.primary.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        pkg.dataLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: pkg.unlimited ? AppTheme.accent : AppTheme.primary,
                        ),
                      ),
                    ),
                    // Daily quota untuk unlimited
                    if (pkg.unlimited && pkg.dailyQuotaGb > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${pkg.dailyQuotaGb % 1 == 0 ? pkg.dailyQuotaGb.toInt() : pkg.dailyQuotaGb}GB/hari',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                    if (pkg.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text('⭐', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    const Spacer(),
                    // Harga — teal bold
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(pkg.priceIdr),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Text(
                          'per paket',
                          style: TextStyle(fontSize: 10, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Baris 2: Durasi + tag fitur ──
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      pkg.durationLabel,
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    _SpeedTag(speed: pkg.speed, color: supplierColor),
                    if (pkg.hotspot) ...[
                      const SizedBox(width: 6),
                      _SmallTag(
                        icon: Icons.wifi_tethering,
                        label: 'Hotspot',
                        color: const Color(0xFF0891B2),
                      ),
                    ],
                    if (pkg.isRegional) ...[
                      const SizedBox(width: 6),
                      _SmallTag(
                        icon: Icons.public_outlined,
                        label: '${pkg.supportedCountries.length} negara',
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),

                // ── Baris 3: Tombol ──
                Row(
                  children: [
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => context.push('/package-detail', extra: {
                          'package': pkg,
                          'countryName': countryName,
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout', extra: {
                            'package': pkg,
                            'countryName': countryName,
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 14),
                              SizedBox(width: 5),
                              Text('Beli Sekarang',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Speed tag ─────────────────────────────────────────────────────────────────

class _SpeedTag extends StatelessWidget {
  final String speed;
  final Color color;

  const _SpeedTag({required this.speed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt, size: 11, color: color),
          const SizedBox(width: 3),
          Text(speed, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Small feature tag ─────────────────────────────────────────────────────────

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Empty / error ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 44, color: AppTheme.textGrey),
          SizedBox(height: 10),
          Text('Tidak ada paket tersedia', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 44, color: AppTheme.danger),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
