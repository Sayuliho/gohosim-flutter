import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: auth.state != AuthState.authenticated
          ? _NotLoggedIn()
          : _ProfileContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/my-esims');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.sim_card_outlined), selectedIcon: Icon(Icons.sim_card), label: 'eSIM Saya'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final user  = auth.user!;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    const isGoogle = false; // Google login belum diimplementasi di model

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primary,
                    child: Text(initial,
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                        Text(user.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        Text(user.email,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGoogle ? Icons.g_mobiledata : Icons.email_outlined,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isGoogle ? 'Google' : 'Email',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Menu Card ─────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                    label: 'Informasi Akun',
                    onTap: () => _showEditProfile(context),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.sim_card_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                    label: 'My eSIM',
                    onTap: () => context.push('/my-esims'),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    iconBg: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Riwayat Order',
                    onTap: () => context.push('/my-esims'),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF16A34A),
                    label: 'Kebijakan Privasi',
                    onTap: () => _showInfoSheet(context, 'Kebijakan Privasi', _privacyText),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    iconBg: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFF97316),
                    label: 'Syarat & Ketentuan',
                    onTap: () => _showInfoSheet(context, 'Syarat & Ketentuan', _termsText),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.star_outline,
                    iconBg: const Color(0xFFFFFBEB),
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Beri Rating',
                    onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.gohosim.app'),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.chat_bubble_outline,
                    iconBg: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF22C55E),
                    label: 'Hubungi CS',
                    onTap: () => _launchUrl('https://wa.me/6282167782222?text=Halo%20GohoSIM%2C%20saya%20butuh%20bantuan'),
                  ),
                  const _Divider(),
                  _MenuItem(
                    icon: Icons.logout,
                    iconBg: const Color(0xFFFEF2F2),
                    iconColor: AppTheme.danger,
                    label: 'Keluar',
                    labelColor: AppTheme.danger,
                    chevronColor: AppTheme.danger,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(children: [
                Text(title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(_), icon: const Icon(Icons.close)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.all(16),
                child: Text(content,
                    style: const TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF374151))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AuthProvider>(),
        child: const _EditProfileSheet(),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }
}

// ── Teks Kebijakan & Syarat ────────────────────────────────────────────────
const _privacyText = '''
GohoSIM berkomitmen menjaga privasi pengguna.

1. Data yang Dikumpulkan
Kami mengumpulkan nama, email, dan nomor WhatsApp yang kamu berikan saat mendaftar, serta data transaksi pembelian eSIM.

2. Penggunaan Data
Data digunakan untuk memproses pesanan, mengirim konfirmasi, dan memberikan dukungan pelanggan.

3. Keamanan Data
Data kamu disimpan dengan aman dan tidak dijual atau dibagikan kepada pihak ketiga tanpa persetujuan kamu, kecuali untuk keperluan pemrosesan pesanan (supplier eSIM).

4. Hak Pengguna
Kamu dapat memperbarui atau menghapus akun kamu kapan saja melalui menu Profil.

5. Kontak
Pertanyaan seputar privasi: cs@gohosim.com
''';

const _termsText = '''
Terakhir diperbarui: 30 Oktober 2026

1. KETENTUAN UMUM

Dengan membeli atau menggunakan eSIM melalui GohoSIM, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan ini.

GohoSIM adalah layanan eSIM perjalanan yang bertindak sebagai reseller dari penyedia jaringan internasional. Layanan jaringan disediakan oleh mitra pihak ketiga; GohoSIM tidak mengoperasikan jaringan sendiri.

2. KOMPATIBILITAS PERANGKAT

• Pelanggan wajib memastikan perangkat mendukung teknologi eSIM sebelum melakukan pembelian.
• GohoSIM tidak bertanggung jawab atas pembelian eSIM yang tidak dapat digunakan karena perangkat tidak kompatibel.
• Perangkat harus tidak terkunci (unlocked) dari operator asal agar eSIM dapat berfungsi.

3. AKTIVASI DAN PENGGUNAAN

• eSIM dikirimkan dalam bentuk QR Code melalui email dan akun GohoSIM Anda.
• QR Code hanya dapat di-scan satu kali untuk instalasi. Setelah terpasang, tidak dapat dipindahkan ke perangkat lain.
• Paket aktivasi otomatis: mulai berjalan saat eSIM pertama kali terhubung ke jaringan.
• Paket aktivasi manual: mulai berjalan sesuai waktu yang ditentukan saat instalasi.
• eSIM yang sudah diinstal tidak dapat dikembalikan ke kondisi semula.

4. KEBIJAKAN REFUND DAN PEMBATALAN

Refund dapat dipertimbangkan hanya jika:
• eSIM belum diinstal dan belum digunakan sama sekali (pengajuan dalam 30 hari sejak pembelian)
• Masalah teknis dari sisi penyedia jaringan yang tidak dapat diselesaikan, tanpa ada data yang telah digunakan
• Gangguan jaringan signifikan yang dikonfirmasi oleh penyedia, dalam 30 hari sejak pembelian

Refund TIDAK dapat diberikan untuk:
• eSIM yang sudah diinstal dan/atau sudah ada penggunaan data
• Sisa kuota yang tidak terpakai setelah masa berlaku habis
• Pembelian lebih dari 60 hari yang lalu
• Perangkat tidak kompatibel atau terkunci (locked)
• Kualitas sinyal yang buruk di area tertentu
• eSIM Virtual Number yang tidak menerima kode OTP

Prosedur refund: Hubungi CS via WhatsApp dalam 30 hari sejak pembelian, sertakan nomor order, email, ICCID, dan penjelasan masalah. Proses verifikasi 3–7 hari kerja.

5. FAIR USAGE POLICY (FUP)

Beberapa paket memiliki batas kecepatan (throttle) setelah kuota tertentu habis — tercantum di deskripsi masing-masing paket. Penggunaan tethering/hotspot diperbolehkan pada paket yang mendukungnya.

6. KETERSEDIAAN LAYANAN

GohoSIM tidak menjamin ketersediaan jaringan 100% tanpa gangguan. Kualitas layanan bergantung pada jaringan mitra di masing-masing negara tujuan. GohoSIM tidak bertanggung jawab atas kerugian akibat gangguan jaringan, keterlambatan aktivasi, atau ketidaktersediaan layanan.

7. PRIVASI DAN DATA

Data pribadi pelanggan dikelola sesuai peraturan perlindungan data yang berlaku di Indonesia dan tidak dibagikan kepada pihak ketiga selain yang diperlukan untuk pemenuhan layanan.

8. BATASAN TANGGUNG JAWAB

Tanggung jawab maksimal GohoSIM terbatas pada nilai pembelian paket yang bersangkutan.

9. PERUBAHAN SYARAT DAN KETENTUAN

GohoSIM berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Penggunaan layanan setelah perubahan berlaku berarti pelanggan menyetujui syarat dan ketentuan yang baru.

10. KONTAK DAN BANTUAN

WhatsApp CS : 018132210
Jam Layanan : Senin–Minggu, 08.00–21.00 WIB
''';

// ── Menu Item ──────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Color? chevronColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: labelColor ?? const Color(0xFF111827),
                  )),
            ),
            Icon(Icons.chevron_right, color: chevronColor ?? const Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 70, endIndent: 16);
}

// ── Edit Profile Bottom Sheet ──────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();
  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _waCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user  = context.read<AuthProvider>().user;
    _nameCtrl   = TextEditingController(text: user?.name ?? '');
    _waCtrl     = TextEditingController(text: user?.wa ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateProfile(
      _nameCtrl.text.trim(),
      _waCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20,
          20 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Informasi Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: auth.user?.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _waCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 10),
              Text(auth.error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Not Logged In ──────────────────────────────────────────────────────────
class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            const Text('Belum masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Masuk untuk mengelola akun dan melihat histori eSIM kamu',
                style: TextStyle(color: AppTheme.textGrey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Masuk / Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
