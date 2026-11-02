import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/app_theme.dart';

class EsimCheckScreen extends StatefulWidget {
  const EsimCheckScreen({super.key});

  @override
  State<EsimCheckScreen> createState() => _EsimCheckScreenState();
}

class _EsimCheckScreenState extends State<EsimCheckScreen> {
  static const _channel = MethodChannel('com.gohotravel.gohosim/esim');

  _CheckStatus _status = _CheckStatus.idle;
  bool _hasHardware = false;
  bool _isEnabled = false;
  bool _apiSupported = false;

  Future<void> _runCheck() async {
    setState(() => _status = _CheckStatus.checking);
    try {
      final result = await _channel.invokeMapMethod<String, bool>('checkEsimSupport');
      setState(() {
        _apiSupported  = result?['apiSupported'] ?? false;
        _hasHardware   = result?['hasHardware']  ?? false;
        _isEnabled     = result?['isEnabled']    ?? false;
        _status = _CheckStatus.done;
      });
    } on PlatformException {
      setState(() => _status = _CheckStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cek Kompatibilitas eSIM',
          style: TextStyle(color: AppTheme.textDark, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF00A8B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📱', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  const Text(
                    'HP Kamu Support eSIM?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Deteksi otomatis + panduan manual tersedia',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Deteksi otomatis ──
            const Text(
              'Deteksi Otomatis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  if (_status == _CheckStatus.idle) ...[
                    const Text(
                      'Ketuk tombol di bawah untuk mengecek apakah HP kamu mendukung eSIM secara otomatis.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _runCheck,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Cek Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],

                  if (_status == _CheckStatus.checking)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        SizedBox(height: 12),
                        Text('Mengecek...', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                      ]),
                    ),

                  if (_status == _CheckStatus.done) ...[
                    _ResultCard(
                      apiSupported: _apiSupported,
                      hasHardware: _hasHardware,
                      isEnabled: _isEnabled,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _status = _CheckStatus.idle),
                      child: const Text('Cek Ulang', style: TextStyle(color: AppTheme.primary)),
                    ),
                  ],

                  if (_status == _CheckStatus.error) ...[
                    const Icon(Icons.error_outline, color: Colors.orange, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Gagal melakukan pengecekan. Gunakan panduan manual di bawah.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _status = _CheckStatus.idle),
                      child: const Text('Coba Lagi', style: TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '* Kompatibilitas dengan operator perlu dicek terpisah. eSIM tersedia di hardware belum tentu aktif oleh operator.',
                style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
              ),
            ),

            const SizedBox(height: 24),

            // ── Panduan Manual ──
            const Text(
              'Panduan Cek Manual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),

            _StepCard(
              icon: '🤖',
              title: 'Android',
              steps: const [
                'Buka Pengaturan (Settings)',
                'Pilih Koneksi → Manajer SIM',
                'Jika ada opsi "Tambah eSIM" atau "eSIM", HP kamu support eSIM ✅',
              ],
            ),
            const SizedBox(height: 12),
            _StepCard(
              icon: '🍎',
              title: 'iPhone',
              steps: const [
                'Buka Pengaturan (Settings)',
                'Pilih Seluler / Cellular',
                'Jika ada opsi "Tambahkan eSIM", iPhone kamu support eSIM ✅',
              ],
            ),
            const SizedBox(height: 24),

            // HP yang support
            const Text(
              'HP Populer yang Support eSIM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),
            _BrandSection(brand: 'Samsung', models: const [
              'Galaxy S21, S22, S23, S24 (semua varian)',
              'Galaxy Z Fold 3/4/5/6 · Z Flip 3/4/5/6',
              'Galaxy A54, A55',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'iPhone', models: const [
              'iPhone XS, XS Max, XR ke atas',
              'iPhone 11, 12, 13, 14, 15, 16 (semua varian)',
              'iPhone SE (2020, 2022)',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'Google Pixel', models: const [
              'Pixel 3 ke atas',
              'Pixel 6, 7, 8, 9 (semua varian)',
            ]),
            const SizedBox(height: 10),
            _BrandSection(brand: 'Oppo / OnePlus', models: const [
              'Find X3 Pro, Find X5, Find X6, Find X7',
              'OnePlus 11, 12',
            ]),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HP entry-level atau varian tertentu (Samsung A14, Xiaomi Redmi) umumnya belum support eSIM. Cek spesifikasi resmi jika tidak yakin.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final bool apiSupported;
  final bool hasHardware;
  final bool isEnabled;

  const _ResultCard({
    required this.apiSupported,
    required this.hasHardware,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    // Android < 9
    if (!apiSupported) {
      return _buildResult(
        icon: '❓',
        color: Colors.orange,
        title: 'Perlu pengecekan manual',
        subtitle: 'Android kamu di bawah versi 9. Deteksi otomatis tidak tersedia — gunakan panduan manual di bawah.',
      );
    }

    // Hardware ada dan aktif
    if (hasHardware && isEnabled) {
      return _buildResult(
        icon: '✅',
        color: const Color(0xFF16A34A),
        title: 'Fitur eSIM tersedia di HP kamu!',
        subtitle: 'Hardware eSIM terdeteksi dan sedang aktif. Kamu bisa langsung pasang paket eSIM GohoSIM.',
      );
    }

    // Hardware ada tapi tidak aktif (mungkin diblokir operator)
    if (hasHardware && !isEnabled) {
      return _buildResult(
        icon: '⚠️',
        color: Colors.orange,
        title: 'Hardware eSIM ada, tapi fitur tidak aktif',
        subtitle: 'HP kamu punya hardware eSIM, namun fitur sedang tidak tersedia — kemungkinan dibatasi oleh operator atau pengaturan HP.',
      );
    }

    // Tidak ada hardware / tidak terdeteksi
    return _buildResult(
      icon: '❌',
      color: const Color(0xFFDC2626),
      title: 'Fitur eSIM tidak terdeteksi',
      subtitle: 'HP kamu kemungkinan belum mendukung eSIM atau fitur sedang tidak tersedia saat ini.',
    );
  }

  Widget _buildResult({
    required String icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> steps;

  const _StepCard({required this.icon, required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
          ]),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Brand section ─────────────────────────────────────────────────────────────

class _BrandSection extends StatelessWidget {
  final String brand;
  final List<String> models;

  const _BrandSection({required this.brand, required this.models});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
          const SizedBox(height: 6),
          ...models.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                Expanded(child: Text(m, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

enum _CheckStatus { idle, checking, done, error }
