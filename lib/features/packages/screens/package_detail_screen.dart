import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

// Warna supplier (sama dengan packages_screen)
Color _supplierColor(String supplier) {
  switch (supplier) {
    case 'ir': return const Color(0xFF16A34A);
    case 'ec': return const Color(0xFF7C3AED);
    default:   return const Color(0xFF0EA5E9);
  }
}
String _supplierLabel(String supplier) {
  switch (supplier) {
    case 'ir': return 'iRoamly';
    case 'ec': return 'eSIMCard';
    default:   return 'eSIM Access';
  }
}

class PackageDetailScreen extends StatelessWidget {
  final EsimPackage pkg;
  final String countryName;

  const PackageDetailScreen({
    super.key,
    required this.pkg,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    final idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final supplierColor = _supplierColor(pkg.supplier);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Paket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),

      // ── Bottom bar: Beli Sekarang ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            // Harga besar di kiri
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harga', style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                Text(
                  idr.format(pkg.priceIdr),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Tombol Beli
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/checkout', extra: {
                  'package': pkg,
                  'countryName': countryName,
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Beli Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero section ──
            Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data badge besar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pkg.dataLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    countryName,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    pkg.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info paket ──
            _Section(
              title: 'Spesifikasi Paket',
              children: [
                _InfoRow(icon: Icons.data_usage, label: 'Data', value: pkg.dataLabel),
                _InfoRow(icon: Icons.calendar_today_outlined, label: 'Durasi', value: pkg.durationLabel),
                _InfoRow(
                  icon: Icons.signal_cellular_alt,
                  label: 'Kecepatan',
                  value: pkg.speed,
                  valueColor: supplierColor,
                ),
                _InfoRow(
                  icon: Icons.wifi_tethering,
                  label: 'Hotspot',
                  value: pkg.hotspot ? '✅ Tersedia' : '❌ Tidak tersedia',
                ),
                if (pkg.unlimited)
                  _InfoRow(
                    icon: Icons.all_inclusive,
                    label: 'Tipe',
                    value: pkg.dailyQuotaGb > 0
                        ? 'Unlimited (${pkg.dailyQuotaGb % 1 == 0 ? pkg.dailyQuotaGb.toInt() : pkg.dailyQuotaGb}GB/hari)'
                        : 'Unlimited / Hari',
                  )
                else
                  const _InfoRow(
                    icon: Icons.sim_card_outlined,
                    label: 'Tipe',
                    value: 'Fixed Data',
                  ),
                if (pkg.isPremium)
                  const _InfoRow(
                    icon: Icons.star_outline,
                    label: 'Grade',
                    value: '⭐ Premium',
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Jaringan & Aktivasi ──
            _Section(
              title: 'Jaringan & Aktivasi',
              children: [
                const _InfoRow(
                  icon: Icons.public_outlined,
                  label: 'Aktivasi',
                  value: 'Otomatis via QR Code',
                ),
                const _InfoRow(
                  icon: Icons.phone_android_outlined,
                  label: 'Syarat',
                  value: 'HP harus support eSIM',
                ),
              ],
            ),

            // ── Negara yang tercakup (untuk paket regional) ──
            if (pkg.isRegional && pkg.supportedCountries.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Section(
                title: 'Negara yang Tercakup (${pkg.supportedCountries.length} negara)',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: pkg.supportedCountries.map((code) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFD0FF)),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B4FBB)),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // ── Cara pakai ──
            _Section(
              title: 'Cara Menggunakan',
              children: [
                _StepRow(no: '1', text: 'Scan QR Code yang dikirim via email'),
                _StepRow(no: '2', text: 'Tambahkan eSIM ke pengaturan HP'),
                _StepRow(no: '3', text: 'Aktifkan eSIM saat tiba di $countryName'),
                _StepRow(no: '4', text: 'Nikmati internet tanpa roaming! 🎉'),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Widgets helper ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String no;
  final String text;

  const _StepRow({required this.no, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(no, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
