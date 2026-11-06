import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class MyEsimsScreen extends StatefulWidget {
  const MyEsimsScreen({super.key});

  @override
  State<MyEsimsScreen> createState() => _MyEsimsScreenState();
}

class _MyEsimsScreenState extends State<MyEsimsScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.state != AuthState.authenticated) {
      setState(() { _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    final res = await ApiClient.get('/my-esims', auth: true);
    if (!mounted) return;
    if (res['ok'] == true) {
      final list = (res['esims'] as List?)
          ?.map((j) => Order.fromJson(j))
          .where((o) => o.status != 'cancelled')
          .toList() ?? [];
      setState(() { _orders = list; _loading = false; });
    } else {
      setState(() { _error = res['error'] ?? 'Gagal memuat data'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('eSIM Saya'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: auth.state != AuthState.authenticated
          ? _NotLoggedIn()
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorView(error: _error!, onRetry: _load)
                  : _orders.isEmpty
                      ? _EmptyView()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _orders.length,
                            itemBuilder: (ctx, i) => _OrderCard(
                              order: _orders[i],
                              onCancelled: () => setState(() {
                                _orders.removeAt(i);
                              }),
                            ),
                          ),
                        ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/home');
          if (i == 2) context.push('/profile');
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

class _OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onCancelled;
  const _OrderCard({required this.order, this.onCancelled});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _cancelling = false;

  Order get order => widget.order;

  Future<void> _cancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Order?'),
        content: Text('Order #${order.orderRef} akan dibatalkan dan tidak bisa diaktifkan kembali.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    setState(() => _cancelling = true);
    final res = await ApiClient.patch('/order/${order.orderRef}/cancel', {}, auth: true);
    if (!context.mounted) return;
    setState(() => _cancelling = false);
    if (res['ok'] == true) {
      widget.onCancelled?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Gagal membatalkan order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (order.status) {
      case 'active':
        statusColor = AppTheme.success;
        statusLabel = 'Aktif';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending_payment':
        statusColor = Colors.orange;
        statusLabel = 'Menunggu Bayar';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'processing':
        statusColor = AppTheme.accent;
        statusLabel = 'Diproses';
        statusIcon = Icons.sync;
        break;
      case 'expired':
        statusColor = AppTheme.textGrey;
        statusLabel = 'Kedaluwarsa';
        statusIcon = Icons.timer_off_outlined;
        break;
      default:
        statusColor = AppTheme.textGrey;
        statusLabel = order.status;
        statusIcon = Icons.info_outline;
    }

    // Judul: "Japan" atau "JP" lalu paket ringkas "3GB / 3 Hari"
    final countryDisplay = order.countryDisplayName;
    final packageSummary = '${order.dataLabel} / ${order.durationLabel}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: nama negara + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (countryDisplay.isNotEmpty) ...[
                        Text(
                          countryDisplay,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        packageSummary,
                        style: TextStyle(
                          fontSize: countryDisplay.isEmpty ? 17 : 14,
                          fontWeight: countryDisplay.isEmpty ? FontWeight.bold : FontWeight.normal,
                          color: countryDisplay.isEmpty ? null : AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '#${order.orderRef}',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 11, fontFamily: 'monospace'),
            ),

            // QR / aktivasi
            if (order.qrCodeUrl != null || order.activationCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktivasi eSIM',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    if (order.activationCode != null)
                      SelectableText(
                        order.activationCode!,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppTheme.textDark),
                      ),
                    if (order.iccid != null)
                      Text('ICCID: ${order.iccid}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                  ],
                ),
              ),
            ],

            // Tombol aksi untuk pending_payment
            if (order.status == 'pending_payment') ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _resumePayment(context, order),
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Bayar Sekarang'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _cancelling ? null : () => _cancelOrder(context),
                icon: _cancelling
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                label: Text(_cancelling ? 'Membatalkan...' : 'Batalkan Order',
                    style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],

            // Tombol cancel untuk pending biasa
            if (order.status == 'pending') ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _cancelling ? null : () => _cancelOrder(context),
                icon: _cancelling
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                label: Text(_cancelling ? 'Membatalkan...' : 'Batalkan Order',
                    style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _resumePayment(BuildContext context, Order order) async {
    if (order.snapToken == null) return;
    // Ambil fresh snap token dari server (endpoint GET dengan query param)
    final res = await ApiClient.get(
      '/midtrans/resume-payment?order_ref=${order.orderRef}',
      auth: true,
    );
    if (!context.mounted) return;
    if (res['ok'] == true && res['snap_token'] != null) {
      final snapToken = res['snap_token'] as String;
      final snapUrl   = res['snap_url'] as String? ??
          'https://app.sandbox.midtrans.com/snap/snap.js';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SnapWebView(
            snapToken: snapToken,
            snapUrl: snapUrl,
            onSuccess: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Pembayaran berhasil! eSIM sedang diproses'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            onPending: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran pending — cek berkala')),
              );
            },
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Gagal membuka pembayaran')),
      );
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textGrey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
      ],
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            const Text('Masuk untuk melihat eSIM kamu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Histori pembelian eSIM tersimpan di akunmu',
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

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sim_card_outlined, size: 64, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            const Text('Belum ada eSIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Beli eSIM pertamamu sekarang!',
                style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Lihat Paket'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

// ── Snap WebView untuk resume payment ────────────────────────────
class _SnapWebView extends StatefulWidget {
  final String snapToken;
  final String snapUrl;
  final VoidCallback onSuccess;
  final VoidCallback onPending;
  final VoidCallback onClose;

  const _SnapWebView({
    required this.snapToken,
    required this.snapUrl,
    required this.onSuccess,
    required this.onPending,
    required this.onClose,
  });

  @override
  State<_SnapWebView> createState() => _SnapWebViewState();
}

class _SnapWebViewState extends State<_SnapWebView> {
  late final WebViewController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            final url = req.url;
            if (url.contains('gohosim-success') || url.contains('status=success')) {
              widget.onSuccess();
              return NavigationDecision.prevent;
            }
            if (url.contains('gohosim-pending') || url.contains('status=pending')) {
              widget.onPending();
              return NavigationDecision.prevent;
            }
            if (url.contains('gohosim-error') || url.contains('status=error')) {
              widget.onClose();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildSnapHtml());
  }

  String _buildSnapHtml() => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="${widget.snapUrl}" data-client-key=""></script>
</head>
<body style="margin:0;padding:0;background:#f5f7fa;">
<script>
  window.onload = function() {
    snap.pay('${widget.snapToken}', {
      onSuccess: function(r) { window.location = 'gohosim-success://'; },
      onPending: function(r) { window.location = 'gohosim-pending://'; },
      onError:   function(r) { window.location = 'gohosim-error://'; },
      onClose:   function()  { window.location = 'gohosim-error://'; }
    });
  };
</script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}
