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
  String _coverage  = 'single';   // 'single' | 'regional'
  String _typeFilter = 'all';      // 'all' | 'fixed' | 'unlimited'

  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Urutan tampilan group GB
  static const _gbOrder = [3.0, 5.0, 10.0, 20.0, 30.0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackagesProvider>().fetchPackages(widget.countryCode);
    });
  }

  /// Filter + urutkan paket
  List<EsimPackage> _filtered(List<EsimPackage> pkgs) {
    var list = pkgs.where((p) => p.isVisible).toList();
    if (_typeFilter == 'fixed')     list = list.where((p) => !p.unlimited).toList();
    if (_typeFilter == 'unlimited') list = list.where((p) => p.unlimited).toList();
    return list;
  }

  /// Kelompokkan per kuota GB, urutan sesuai _gbOrder lalu Unlimited
  Map<String, List<EsimPackage>> _group(List<EsimPackage> pkgs) {
    final result = <String, List<EsimPackage>>{};
    // Fixed: urutkan group GB sesuai _gbOrder
    for (final gb in _gbOrder) {
      final items = pkgs
          .where((p) => !p.unlimited && p.dataGb == gb)
          .toList()
        ..sort((a, b) => a.durationDays.compareTo(b.durationDays));
      if (items.isNotEmpty) result['${gb.toInt()} GB'] = items;
    }
    // Unlimited
    final unl = pkgs.where((p) => p.unlimited).toList()
      ..sort((a, b) => a.durationDays.compareTo(b.durationDays));
    if (unl.isNotEmpty) result['Unlimited'] = unl;
    return result;
  }

  int _count(String t, List<EsimPackage> all) {
    final list = all.where((p) => p.isVisible).toList();
    if (t == 'fixed')     return list.where((p) => !p.unlimited).length;
    if (t == 'unlimited') return list.where((p) => p.unlimited).length;
    return list.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<PackagesProvider>();
    final singlePkgs  = provider.packages;
    final regionalPkgs = provider.bundles;

    final displayPkgs = _coverage == 'regional' ? regionalPkgs : singlePkgs;
    final isLoading   = _coverage == 'regional' ? provider.loadingBundles : provider.loading;
    final hasError    = _coverage == 'regional' ? provider.bundlesError != null : provider.error != null;
    final errorMsg    = _coverage == 'regional' ? (provider.bundlesError ?? '') : (provider.error ?? '');

    final filtered = _filtered(displayPkgs);
    final grouped  = _group(filtered);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
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

          // ── Header teal ──────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              children: [
                // Flag + nama + jumlah
                Row(children: [
                  if ((widget.countryFlag ?? '').isNotEmpty) ...[
                    Text(widget.countryFlag!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(widget.countryName,
                        style: const TextStyle(color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (!isLoading && !hasError)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${filtered.length} paket',
                          style: const TextStyle(color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 12),

                // Coverage tab
                _CompactTab(options: [
                  _TabOpt(
                    label: 'Negara Ini',
                    count: provider.loading ? null : _count('all', singlePkgs),
                    active: _coverage == 'single',
                    onTap: () => setState(() { _coverage = 'single'; _typeFilter = 'all'; }),
                  ),
                  _TabOpt(
                    label: 'Multi Negara',
                    count: provider.loadingBundles ? null : _count('all', regionalPkgs),
                    active: _coverage == 'regional',
                    onTap: () => setState(() { _coverage = 'regional'; _typeFilter = 'all'; }),
                  ),
                ]),

                // Type filter (hanya untuk single)
                if (_coverage == 'single') ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    _TypeChip(label: 'Semua',    active: _typeFilter == 'all',
                        onTap: () => setState(() => _typeFilter = 'all')),
                    const SizedBox(width: 6),
                    _TypeChip(label: 'Fixed',
                        count: provider.loading ? null : _count('fixed', singlePkgs),
                        active: _typeFilter == 'fixed',
                        onTap: () => setState(() => _typeFilter = 'fixed')),
                    const SizedBox(width: 6),
                    _TypeChip(label: 'Unlimited',
                        count: provider.loading ? null : _count('unlimited', singlePkgs),
                        active: _typeFilter == 'unlimited',
                        onTap: () => setState(() => _typeFilter = 'unlimited')),
                  ]),
                ],
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : hasError
                    ? _ErrorState(message: errorMsg,
                        onRetry: () => provider.fetchPackages(widget.countryCode))
                    : filtered.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                            itemCount: grouped.length,
                            itemBuilder: (_, i) {
                              final label  = grouped.keys.elementAt(i);
                              final items  = grouped[label]!;
                              final isUnl  = label == 'Unlimited';
                              return _GroupSection(
                                label: label,
                                isUnlimited: isUnl,
                                items: items,
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

// ── Group section (badge GB + list row per durasi) ────────────────────────────

class _GroupSection extends StatelessWidget {
  final String label;
  final bool isUnlimited;
  final List<EsimPackage> items;
  final NumberFormat idr;
  final String countryName;

  const _GroupSection({
    required this.label,
    required this.isUnlimited,
    required this.items,
    required this.idr,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge header GB
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: isUnlimited ? AppTheme.cta : AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isUnlimited ? AppTheme.cta : AppTheme.primary).withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // Card putih berisi semua durasi untuk kuota ini
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: isUnlimited ? AppTheme.cta : AppTheme.primary,
                width: 3,
              ),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final idx = e.key;
              final pkg = e.value;
              final isLast = idx == items.length - 1;
              return _DurationRow(
                pkg: pkg,
                idr: idr,
                isLast: isLast,
                countryName: countryName,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Row per durasi dalam satu group ──────────────────────────────────────────

class _DurationRow extends StatelessWidget {
  final EsimPackage pkg;
  final NumberFormat idr;
  final bool isLast;
  final String countryName;

  const _DurationRow({
    required this.pkg,
    required this.idr,
    required this.isLast,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    final supplierColor = _supplierColor(pkg.supplier);

    return InkWell(
      onTap: () => context.push('/package-detail', extra: {
        'package': pkg,
        'countryName': countryName,
      }),
      borderRadius: BorderRadius.only(
        bottomLeft:  isLast ? const Radius.circular(12) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                // Kiri: durasi + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Durasi — besar dan bold
                      Text(
                        pkg.durationLabel,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Tags: speed + hotspot + daily quota
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          _SmallTag(
                            icon: Icons.signal_cellular_alt,
                            label: pkg.speed,
                            color: supplierColor,
                          ),
                          if (pkg.hotspot)
                            const _SmallTag(
                              icon: Icons.wifi_tethering,
                              label: 'Hotspot',
                              color: Color(0xFF0891B2),
                            ),
                          if (pkg.unlimited && pkg.dailyQuotaGb > 0)
                            _SmallTag(
                              icon: Icons.all_inclusive,
                              label: '${pkg.dailyQuotaGb % 1 == 0 ? pkg.dailyQuotaGb.toInt() : pkg.dailyQuotaGb}GB/hari',
                              color: AppTheme.cta,
                            ),
                          if (pkg.isRegional)
                            _SmallTag(
                              icon: Icons.public_outlined,
                              label: '${pkg.supportedCountries.length} negara',
                              color: const Color(0xFF7C3AED),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Kanan: harga + tombol beli
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      idr.format(pkg.priceIdr),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => context.push('/checkout', extra: {
                          'package': pkg,
                          'countryName': countryName,
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Beli',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF0EDE0)),
        ],
      ),
    );
  }
}

// ── Small tag ─────────────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
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
                    Text(opt.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: opt.active ? AppTheme.primary : Colors.white,
                        )),
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
                        child: Text('${opt.count}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: opt.active ? AppTheme.primary : Colors.white,
                            )),
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

// ── Type chip ─────────────────────────────────────────────────────────────────

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
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? AppTheme.primary : Colors.white,
                )),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text('($count)',
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? AppTheme.primary.withOpacity(0.7) : Colors.white70,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ],
        ),
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
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13,
                  fontWeight: FontWeight.w600)),
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
          Text(message,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
