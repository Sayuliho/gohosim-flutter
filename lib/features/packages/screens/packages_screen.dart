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

  const PackagesScreen({super.key, required this.countryCode, required this.countryName});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  String _filterData = 'all'; // 'all' | 'limited' | 'unlimited'
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
    if (_filterData == 'unlimited') return all.where((p) => p.unlimited).toList();
    if (_filterData == 'limited') return all.where((p) => !p.unlimited).toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Paket ${widget.countryName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _FilterChip(label: 'Semua', active: _filterData == 'all', onTap: () => setState(() => _filterData = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Kuota', active: _filterData == 'limited', onTap: () => setState(() => _filterData = 'limited')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Unlimited', active: _filterData == 'unlimited', onTap: () => setState(() => _filterData = 'unlimited')),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
                            const SizedBox(height: 12),
                            Text(provider.error!, style: const TextStyle(color: AppTheme.textGrey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.fetchPackages(widget.countryCode),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? const Center(child: Text('Tidak ada paket tersedia'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) {
                              final pkg = _filtered[i];
                              return _PackageCard(
                                pkg: pkg,
                                idr: _idr,
                                onTap: () => context.push('/checkout', extra: {
                                  'package': pkg,
                                  'countryName': widget.countryName,
                                }),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppTheme.primary : const Color(0xFFD1D5DB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textGrey,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final EsimPackage pkg;
  final NumberFormat idr;
  final VoidCallback onTap;

  const _PackageCard({required this.pkg, required this.idr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Data & duration info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: pkg.unlimited
                                ? AppTheme.accent.withOpacity(0.1)
                                : AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(width: 8),
                        if (pkg.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF59E0B)),
                            ),
                            child: const Text('⭐ Premium',
                                style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Text(pkg.durationLabel, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                        const SizedBox(width: 16),
                        const Icon(Icons.speed_outlined, size: 14, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Text(pkg.speed, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                        if (pkg.hotspot) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.wifi_tethering, size: 14, color: AppTheme.textGrey),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Harga + button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    idr.format(pkg.priceIdr),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Beli', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
