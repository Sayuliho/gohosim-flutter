import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/packages_provider.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

// ── Supplier colors (sama dengan dashboard) ───────────────────────────────────
// ea = eSIM Access (biru), ir = iRoamly (hijau), ec = eSIMCard (ungu)
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
  final bool isMultiCountry; // untuk filter Multi Negara

  const PackagesScreen({
    super.key,
    required this.countryCode,
    required this.countryName,
    this.countryFlag,
    this.isMultiCountry = false,
  });

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

// Filter: 'all' | 'fixed' | 'unlimited'
typedef _Filter = String;

class _PackagesScreenState extends State<PackagesScreen> {
  _Filter _filter = 'all';
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
    if (_filter == 'fixed')     return all.where((p) => !p.unlimited).toList();
    return all;
  }

  int _count(_Filter f, List<EsimPackage> all) {
    if (f == 'unlimited') return all.where((p) => p.unlimited).length;
    if (f == 'fixed')     return all.where((p) => !p.unlimited).length;
    return all.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final all = provider.packages;
    final flag = widget.countryFlag ?? '';

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
          // ── Country header + filter 2x2 ────────────────────────
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
                          if (!provider.loading && provider.error == null)
                            Text(
                              '${all.length} pilihan paket',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Filter grid 2x2 seperti PWA
                Row(
                  children: [
                    Expanded(
                      child: _FilterBtn(
                        emoji: '🌍',
                        label: 'Fixed Data',
                        active: _filter == 'fixed',
                        count: provider.loading ? null : _count('fixed', all),
                        onTap: () => setState(() => _filter = _filter == 'fixed' ? 'all' : 'fixed'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterBtn(
                        emoji: '♾️',
                        label: 'Unlimited/Hari',
                        active: _filter == 'unlimited',
                        count: provider.loading ? null : _count('unlimited', all),
                        onTap: () => setState(() => _filter = _filter == 'unlimited' ? 'all' : 'unlimited'),
                      ),
                    ),
                  ],
                ),
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
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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

// ── Filter button (gaya PWA — pill dengan count kecil) ────────────────────────

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
                    if (pkg.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text('⭐',
                            style: TextStyle(fontSize: 12)),
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
                    // Speed tag — warna sesuai supplier
                    _SpeedTag(speed: pkg.speed, color: supplierColor),
                    if (pkg.hotspot) ...[
                      const SizedBox(width: 6),
                      _SmallTag(
                        icon: Icons.wifi_tethering,
                        label: 'Hotspot',
                        color: const Color(0xFF0891B2),
                      ),
                    ],
                    if (pkg.unlimited) ...[
                      const SizedBox(width: 6),
                      _SmallTag(
                        icon: Icons.all_inclusive,
                        label: 'Unlimited',
                        color: AppTheme.accent,
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
                    // Detail — outline teal, slim
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
                    // Beli Sekarang — orange CTA, expand
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

// ── Speed tag — warna = supplier ─────────────────────────────────────────────

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
          Text(
            speed,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
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
