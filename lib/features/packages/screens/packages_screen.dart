import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/packages_provider.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

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
  // Filter: 'all' | 'limited' | 'unlimited'
  String _filter = 'all';
  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackagesProvider>().fetchPackages(widget.countryCode);
    });
  }

  List<EsimPackage> get _filtered {
    final all = context.read<PackagesProvider>().packages;
    if (_filter == 'unlimited') return all.where((p) => p.unlimited).toList();
    if (_filter == 'limited') return all.where((p) => !p.unlimited).toList();
    return all;
  }

  // Counts for filter badges
  int _count(String f, List<EsimPackage> all) {
    if (f == 'unlimited') return all.where((p) => p.unlimited).length;
    if (f == 'limited') return all.where((p) => !p.unlimited).length;
    return all.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final all = provider.packages;
    final flag = widget.countryFlag ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Paket ${widget.countryName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Country header ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                if (flag.isNotEmpty) ...[
                  Text(flag, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.countryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!provider.loading && provider.error == null)
                        Text(
                          '${all.length} paket tersedia',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Filter tabs ─────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'Semua',
                        count: provider.loading ? null : _count('all', all),
                        active: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Kuota',
                        count: provider.loading ? null : _count('limited', all),
                        active: _filter == 'limited',
                        onTap: () => setState(() => _filter = 'limited'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Unlimited',
                        count: provider.loading ? null : _count('unlimited', all),
                        active: _filter == 'unlimited',
                        onTap: () => setState(() => _filter = 'unlimited'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ],
            ),
          ),

          // ── Package list ────────────────────────────────────────
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : provider.error != null
                    ? _ErrorState(
                        message: provider.error!,
                        onRetry: () => provider.fetchPackages(widget.countryCode),
                      )
                    : _filtered.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) {
                              final pkg = _filtered[i];
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

// ── Filter tab ────────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppTheme.primary : const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.textGrey,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.3)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppTheme.textGrey,
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

// ── Package card ──────────────────────────────────────────────────────────────

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/checkout', extra: {
            'package': pkg,
            'countryName': countryName,
          }),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: data badge + premium + price ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data badge — large & prominent
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pkg.unlimited
                            ? AppTheme.accent.withOpacity(0.12)
                            : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: pkg.unlimited
                              ? AppTheme.accent.withOpacity(0.4)
                              : AppTheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        pkg.dataLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: pkg.unlimited ? AppTheme.accent : AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (pkg.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Text(
                          '⭐ Premium',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Price — large, teal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(pkg.priceIdr),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Text(
                          'per paket',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Duration + speed row ──
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 15, color: AppTheme.textGrey),
                    const SizedBox(width: 5),
                    Text(
                      pkg.durationLabel,
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.speed_outlined, size: 15, color: AppTheme.textGrey),
                    const SizedBox(width: 5),
                    Text(
                      pkg.speed,
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Feature tags ──
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (pkg.hotspot)
                      _FeatureTag(
                        icon: Icons.wifi_tethering,
                        label: 'Hotspot',
                        color: const Color(0xFF0EA5E9),
                      ),
                    if (pkg.unlimited)
                      _FeatureTag(
                        icon: Icons.all_inclusive,
                        label: 'Unlimited',
                        color: AppTheme.accent,
                      ),
                    if (!pkg.unlimited)
                      _FeatureTag(
                        icon: Icons.data_usage,
                        label: 'Kuota ${pkg.dataLabel}',
                        color: AppTheme.primary,
                      ),
                    _FeatureTag(
                      icon: Icons.signal_cellular_alt,
                      label: pkg.speed,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),

                // ── Action buttons ──
                Row(
                  children: [
                    // Detail button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/checkout', extra: {
                          'package': pkg,
                          'countryName': countryName,
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Detail',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Beli button — orange CTA
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => context.push('/checkout', extra: {
                          'package': pkg,
                          'countryName': countryName,
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Beli Sekarang',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
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

// ── Feature tag chip ──────────────────────────────────────────────────────────

class _FeatureTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: AppTheme.textGrey),
          SizedBox(height: 12),
          Text('Tidak ada paket tersedia', style: TextStyle(color: AppTheme.textGrey)),
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
          const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
