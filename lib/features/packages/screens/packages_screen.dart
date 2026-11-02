import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/packages_provider.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

// ── Supplier colors ───────────────────────────────────────────────────────────
Color _supplierColor(String supplier) {
  switch (supplier) {
    case 'ir': return const Color(0xFF16A34A);
    case 'ec': return const Color(0xFF7C3AED);
    default:   return const Color(0xFF0EA5E9);
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
  String _coverage = 'single';  // 'single' | 'regional'
  String _typeFilter = 'all';   // 'all' | 'fixed' | 'unlimited'

  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackagesProvider>().fetchPackages(widget.countryCode);
    });
  }

  List<EsimPackage> _applyFilter(List<EsimPackage> pkgs) {
    var list = pkgs.where((p) => p.isAllowedSize).toList();
    if (_typeFilter == 'fixed')     list = list.where((p) => !p.unlimited).toList();
    if (_typeFilter == 'unlimited') list = list.where((p) => p.unlimited).toList();

    // Urutkan: Fixed data dahulu (kecil ke besar, lalu durasi), kemudian Unlimited (durasi asc)
    list.sort((a, b) {
      if (!a.unlimited && b.unlimited) return -1;
      if (a.unlimited && !b.unlimited) return 1;
      if (!a.unlimited) {
        final gbDiff = a.dataGb.compareTo(b.dataGb);
        if (gbDiff != 0) return gbDiff;
      }
      return a.durationDays.compareTo(b.durationDays);
    });
    return list;
  }

  int _count(String t, List<EsimPackage> all) {
    final list = all.where((p) => p.isAllowedSize).toList();
    if (t == 'fixed')     return list.where((p) => !p.unlimited).length;
    if (t == 'unlimited') return list.where((p) => p.unlimited).length;
    return list.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final singlePkgs = provider.packages;
    final regionalPkgs = provider.bundles;
    final flag = widget.countryFlag ?? '';

    final displayPkgs   = _coverage == 'regional' ? regionalPkgs : singlePkgs;
    final isLoading     = _coverage == 'regional' ? provider.loadingBundles : provider.loading;
    final hasError      = _coverage == 'regional' ? provider.bundlesError != null : provider.error != null;
    final errorMsg      = _coverage == 'regional' ? (provider.bundlesError ?? '') : (provider.error ?? '');
    final filtered      = _applyFilter(displayPkgs);

    return Scaffold(
      backgroundColor: AppTheme.bgLight, // cream warm seperti wondr
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.countryName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [

          // ── Header teal (compact) ────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Baris: flag + nama + count
                Row(
                  children: [
                    if (flag.isNotEmpty) ...[
                      Text(flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.countryName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!isLoading && !hasError)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filtered.length} paket',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Single segmented bar: Negara Ini | Multi Negara | Fixed | Unlimited ──
                // Dibagi 2 baris agar tidak sesak:
                // Baris 1: Coverage toggle (compact tab)
                _CompactTab(
                  options: [
                    _TabOpt(
                      label: 'Negara Ini',
                      count: provider.loading ? null : _count('all', singlePkgs),
                      active: _coverage == 'single',
                      onTap: () => setState(() { _coverage = 'single'; _typeFilter = 'all'; }),
                    ),
                    _TabOpt(
                      label: 'Multi Negara',
                      count: provider.loadingBundles ? null : regionalPkgs.length,
                      active: _coverage == 'regional',
                      onTap: () => setState(() { _coverage = 'regional'; _typeFilter = 'all'; }),
                    ),
                  ],
                ),

                // Baris 2: Type filter — hanya untuk single-country
                if (_coverage == 'single') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TypeChip(
                        label: 'Semua',
                        active: _typeFilter == 'all',
                        onTap: () => setState(() => _typeFilter = 'all'),
                      ),
                      const SizedBox(width: 6),
                      _TypeChip(
                        label: 'Fixed',
                        count: provider.loading ? null : _count('fixed', singlePkgs),
                        active: _typeFilter == 'fixed',
                        onTap: () => setState(() => _typeFilter = 'fixed'),
                      ),
                      const SizedBox(width: 6),
                      _TypeChip(
                        label: 'Unlimited',
                        count: provider.loading ? null : _count('unlimited', singlePkgs),
                        active: _typeFilter == 'unlimited',
                        onTap: () => setState(() => _typeFilter = 'unlimited'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : hasError
                    ? _ErrorState(message: errorMsg,
                        onRetry: () => provider.fetchPackages(widget.countryCode))
                    : filtered.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => _PackageCard(
                              pkg: filtered[i],
                              idr: _idr,
                              countryName: widget.countryName,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Compact coverage tab ──────────────────────────────────────────────────────

class _TabOpt {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;
  const _TabOpt({required this.label, this.count, required this.active, required this.onTap});
}

class _CompactTab extends StatelessWidget {
  final List<_TabOpt> options;
  const _CompactTab({required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: options.asMap().entries.map((e) {
          final i = e.key;
          final opt = e.value;
          return Expanded(
            child: GestureDetector(
              onTap: opt.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: opt.active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left:  i == 0 ? const Radius.circular(18) : Radius.zero,
                    right: i == options.length - 1 ? const Radius.circular(18) : Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: opt.active ? AppTheme.primary : Colors.white,
                      ),
                    ),
                    if (opt.count != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: opt.active
                              ? AppTheme.primary.withOpacity(0.12)
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${opt.count}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: opt.active ? AppTheme.primary : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Type chip (Semua / Fixed / Unlimited) ────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  const _TypeChip({required this.label, this.count, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppTheme.primary : Colors.white,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 11,
                  color: active ? AppTheme.primary.withOpacity(0.7) : Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Package card ──────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final EsimPackage pkg;
  final NumberFormat idr;
  final String countryName;

  const _PackageCard({required this.pkg, required this.idr, required this.countryName});

  @override
  Widget build(BuildContext context) {
    final supplierColor = _supplierColor(pkg.supplier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Tambah left border accent sesuai tipe paket
        border: Border(
          left: BorderSide(
            color: pkg.unlimited ? AppTheme.accent : AppTheme.primary,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
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

                // Baris 1: Data + daily quota + premium | Harga
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(pkg.priceIdr),
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const Text('per paket',
                            style: TextStyle(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Baris 2: Durasi + tags
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(pkg.durationLabel,
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    _SpeedTag(speed: pkg.speed, color: supplierColor),
                    if (pkg.hotspot) ...[
                      const SizedBox(width: 6),
                      _SmallTag(icon: Icons.wifi_tethering, label: 'Hotspot',
                          color: const Color(0xFF0891B2)),
                    ],
                    if (pkg.isRegional) ...[
                      const SizedBox(width: 6),
                      _SmallTag(icon: Icons.public_outlined,
                          label: '${pkg.supportedCountries.length} negara',
                          color: const Color(0xFF7C3AED)),
                    ],
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),

                // Baris 3: Tombol
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                        child: const Text('Detail',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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

// ── Empty / Error ─────────────────────────────────────────────────────────────

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
          Text('Tidak ada paket tersedia',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
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
