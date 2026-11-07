import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/package_model.dart';
import '../../../shared/theme/app_theme.dart';

// Terjemahan activation type ke bahasa Indonesia
String _translateActivation(String raw) {
  final lower = raw.toLowerCase().trim();
  if (lower == 'auto' || lower.contains('first network') || lower.contains('first use') || lower.contains('automatic')) {
    return 'Otomatis (aktif saat pertama konek)';
  }
  if (lower == 'manual' || lower.contains('manual activation')) {
    return 'Manual (aktifkan sendiri via Setting HP)';
  }
  if (lower.contains('immediate') || lower.contains('instant')) {
    return 'Langsung aktif setelah instalasi';
  }
  if (lower.contains('purchase') || lower.contains('order')) {
    return 'Aktif sejak pembelian';
  }
  return raw; // fallback tampilkan apa adanya
}

// Persingkat info FUP untuk ditampilkan inline
String _shortenFup(String fup) {
  final match = RegExp(r'(\d+)\s*[Kk][Bb]ps').firstMatch(fup);
  if (match != null) return 'turun ke ${match.group(1)} Kbps setelah FUP';
  if (fup.length > 50) return '${fup.substring(0, 47)}...';
  return fup;
}

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
                  value: pkg.fup.isNotEmpty
                      ? '${pkg.speed}\n(${_shortenFup(pkg.fup)})'
                      : pkg.speed,
                  valueColor: supplierColor,
                  multiLine: pkg.fup.isNotEmpty,
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
                if (pkg.operators.isNotEmpty)
                  _InfoRow(
                    icon: Icons.cell_tower_outlined,
                    label: 'Jaringan / Operator',
                    value: pkg.operators.join(', '),
                    multiLine: true,
                  ),
                _InfoRow(
                  icon: Icons.sim_card_outlined,
                  label: 'Tipe SIM',
                  value: '📍 Local SIM — IP lokal negara tujuan',
                  multiLine: true,
                ),
                _InfoRow(
                  icon: Icons.flash_on_outlined,
                  label: 'Tipe Aktivasi',
                  value: pkg.activationType.isNotEmpty
                      ? '⚡ ${_translateActivation(pkg.activationType)}'
                      : (pkg.supplier == 'ir' || pkg.supplier == 'ec')
                          ? '📋 Lihat panduan aktivasi'
                          : '⚡ Otomatis (aktif saat pertama konek)',
                  multiLine: true,
                ),
                _InfoRow(
                  icon: Icons.map_outlined,
                  label: 'Cakupan',
                  value: pkg.isRegional
                      ? '🌏 Multi negara'
                      : '📍 Satu negara\n${pkg.locationCode.toLowerCase()}',
                  multiLine: true,
                ),
                if (pkg.shelfDays > 0)
                  _InfoRow(
                    icon: Icons.hourglass_top_outlined,
                    label: 'Masa Aktif Sebelum Dipakai',
                    value: '${pkg.shelfDays} hari sejak pembelian',
                    multiLine: true,
                  ),
                if (pkg.apn.isNotEmpty)
                  _InfoRow(
                    icon: Icons.settings_ethernet,
                    label: 'APN Setting',
                    value: pkg.apn,
                  ),
                if (pkg.breakoutIp.isNotEmpty)
                  _InfoRow(
                    icon: Icons.language_outlined,
                    label: 'Asal IP',
                    value: '🌐 ${pkg.breakoutIp}',
                  ),
                _InfoRow(
                  icon: Icons.refresh_outlined,
                  label: 'Top Up',
                  value: pkg.topup ? '✅ Bisa diisi ulang' : '❌ Tidak bisa top up',
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

            // ── Info Paket (shelf days warning) ──
            if (pkg.shelfDays > 0) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jika eSIM tidak diaktifkan dalam ${pkg.shelfDays} hari sejak pembelian, '
                          'paket akan otomatis aktif dan masa berlaku mulai berjalan.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Kartu deskripsi paket unlimited ──
            if (pkg.unlimited && pkg.dailyQuotaGb > 0) ...[
              const SizedBox(height: 12),
              _UnlimitedInfoCard(pkg: pkg),
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
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
          ],
          const SizedBox(height: 8),
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
  final bool multiLine;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom kiri: icon + label, lebar tetap
          SizedBox(
            width: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(icon, size: 14, color: AppTheme.textGrey),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Kolom kanan: nilai, bisa wrap
          Expanded(
            child: Text(
              value,
              textAlign: multiLine ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlimitedInfoCard extends StatelessWidget {
  final EsimPackage pkg;
  const _UnlimitedInfoCard({required this.pkg});

  @override
  Widget build(BuildContext context) {
    final gb = pkg.dailyQuotaGb % 1 == 0
        ? '${pkg.dailyQuotaGb.toInt()}GB'
        : '${pkg.dailyQuotaGb}GB';
    final speed = pkg.speed;

    // Use-case bullets berdasarkan kuota harian
    final List<Map<String, String>> bullets;
    if (pkg.dailyQuotaGb <= 1) {
      bullets = [
        {'icon': '✅', 'text': 'WhatsApp, Maps, browsing'},
        {'icon': '✅', 'text': 'Foto & video pendek'},
        {'icon': '⚠️', 'text': 'Streaming HD – sebaiknya gunakan di awal hari'},
      ];
    } else if (pkg.dailyQuotaGb <= 3) {
      bullets = [
        {'icon': '✅', 'text': 'WhatsApp, Maps, browsing'},
        {'icon': '✅', 'text': 'Video call & streaming SD'},
        {'icon': '✅', 'text': 'Upload foto & media sosial'},
        {'icon': '⚠️', 'text': 'Streaming HD – bisa tapi hemat'},
      ];
    } else {
      bullets = [
        {'icon': '✅', 'text': 'Semua aktivitas standar'},
        {'icon': '✅', 'text': 'Streaming HD lancar'},
        {'icon': '✅', 'text': 'Video call berkualitas tinggi'},
        {'icon': '✅', 'text': 'Upload & download media'},
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.signal_wifi_4_bar, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Internet Unlimited · $gb/hari kecepatan penuh',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              pkg.description.isNotEmpty
                  ? pkg.description
                  : 'Setiap hari kamu mendapat $gb kecepatan $speed penuh. '
                    'Setelah $gb habis, internet tetap jalan tapi lebih lambat '
                    '(untuk chat & maps masih oke). '
                    'Kuota reset otomatis tiap tengah malam waktu setempat.',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...bullets.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['icon']!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b['text']!,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
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
