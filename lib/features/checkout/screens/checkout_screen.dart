import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/package_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  final EsimPackage package;
  final String countryName;

  const CheckoutScreen({super.key, required this.package, required this.countryName});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _waCtrl      = TextEditingController();
  bool _loading      = false;
  String? _error;

  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Pre-fill dari user login
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text  = user.name;
      _emailCtrl.text = user.email;
      _waCtrl.text    = user.wa ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final pkg = widget.package;
    final res = await ApiClient.post('/midtrans/snap-token', {
      'items': [{
        'package_code':  pkg.packageCode,
        'supplier':      pkg.supplier,
        'country':       pkg.locationCode,
        'price_idr':     pkg.priceIdr,
        'price_usd':     pkg.priceUsd,
        'data_gb':       pkg.dataGb,
        'duration_days': pkg.durationDays,
        'country_name':  widget.countryName,
        'qty':           1,
      }],
      'customer_name':  _nameCtrl.text.trim(),
      'customer_email': _emailCtrl.text.trim(),
      'customer_wa':    _waCtrl.text.trim(),
    }, auth: true);

    if (!mounted) return;

    if (res['ok'] == true && res['snap_token'] != null) {
      // Buka Midtrans Snap WebView
      final snapToken = res['snap_token'] as String;
      setState(() => _loading = false);
      _openSnapPayment(snapToken);
    } else {
      setState(() {
        _loading = false;
        _error = res['error'] ?? 'Gagal membuat order';
      });
    }
  }

  void _openSnapPayment(String snapToken) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SnapWebView(
          snapToken: snapToken,
          onSuccess: (orderRef) {
            Navigator.pop(context);
            context.go('/my-esims');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Pembayaran berhasil! eSIM sedang diproses'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          onPending: () {
            Navigator.pop(context);
            context.go('/my-esims');
          },
          onError: () {
            Navigator.pop(context);
            setState(() => _error = 'Pembayaran gagal atau dibatalkan');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pembelian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paket yang dipilih', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${pkg.dataLabel} • ${pkg.durationLabel}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(widget.countryName, style: const TextStyle(color: AppTheme.textGrey)),
                            Text(pkg.speed, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          ],
                        ),
                        Text(
                          _idr.format(pkg.priceIdr),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Data Pemesan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
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
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (opsional)',
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
                      hintText: '08xxxxxxxxxx',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nomor WA wajib diisi';
                      if (v.length < 10) return 'Nomor WA tidak valid';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.danger))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Total & checkout button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran'),
                      Text(
                        _idr.format(pkg.priceIdr),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _checkout,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Bayar Sekarang'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pembayaran aman via Midtrans • Transfer / QRIS / Virtual Account',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Midtrans Snap WebView ──────────────────────────────────────
class _SnapWebView extends StatefulWidget {
  final String snapToken;
  final void Function(String? orderRef) onSuccess;
  final VoidCallback onPending;
  final VoidCallback onError;

  const _SnapWebView({
    required this.snapToken,
    required this.onSuccess,
    required this.onPending,
    required this.onError,
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
              widget.onSuccess(null);
              return NavigationDecision.prevent;
            }
            if (url.contains('gohosim-pending') || url.contains('status=pending')) {
              widget.onPending();
              return NavigationDecision.prevent;
            }
            if (url.contains('gohosim-error') || url.contains('status=error')) {
              widget.onError();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_buildSnapHtml(widget.snapToken));
  }

  String _buildSnapHtml(String token) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://app.sandbox.midtrans.com/snap/snap.js"
    data-client-key="SB-Mid-client-YOUR_CLIENT_KEY"></script>
</head>
<body style="margin:0;padding:0;background:#f5f7fa;">
<script>
  window.onload = function() {
    snap.pay('$token', {
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
          onPressed: () { widget.onError(); },
        ),
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}
