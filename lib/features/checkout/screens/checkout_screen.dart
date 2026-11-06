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
  final _promoCtrl = TextEditingController();
  bool _loading    = false;
  bool _applyingPromo = false;
  String? _error;
  String? _promoMessage;
  bool _promoValid = false;
  int _discount    = 0;

  final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  int get _finalPrice => (widget.package.priceIdr - _discount).clamp(0, widget.package.priceIdr);

  Future<void> _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() { _applyingPromo = true; _promoMessage = null; });

    // TODO: implement promo code validation endpoint
    // For now just show "not valid"
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _applyingPromo = false;
      _promoValid = false;
      _promoMessage = 'Kode promo tidak ditemukan';
      _discount = 0;
    });
  }

  Future<void> _checkout() async {
    setState(() { _loading = true; _error = null; });

    final user = context.read<AuthProvider>().user;
    final pkg  = widget.package;

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
      'customer_name':  user?.name ?? '',
      'customer_email': user?.email ?? '',
      'customer_wa':    user?.wa ?? '',
      if (_promoValid && _promoCtrl.text.isNotEmpty) 'promo_code': _promoCtrl.text.trim(),
    }, auth: true);

    if (!mounted) return;

    if (res['ok'] == true && res['snap_token'] != null) {
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Paket card ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Flag
                  Text(
                    _countryFlag(pkg.locationCode),
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.countryName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pkg.dataLabel} · ${pkg.durationLabel}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        Text(
                          pkg.speed,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _idr.format(pkg.priceIdr),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Promo code ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                border: _promoValid
                    ? Border.all(color: AppTheme.success, width: 1.5)
                    : (_promoMessage != null && !_promoValid)
                        ? Border.all(color: AppTheme.danger, width: 1.5)
                        : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _promoCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Punya kode promo?',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) {
                        if (_promoMessage != null) {
                          setState(() { _promoMessage = null; _promoValid = false; _discount = 0; });
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: _applyingPromo ? null : _applyPromo,
                    child: _applyingPromo
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            'Pakai',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (_promoMessage != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _promoMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _promoValid ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Order summary ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Order',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  _summaryRow('Harga eSIM', _idr.format(pkg.priceIdr)),
                  if (_discount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow('Diskon Promo', '- ${_idr.format(_discount)}', valueColor: AppTheme.success),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        _idr.format(_finalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                      ),
                    ],
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Pay button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 10),
            const Center(
              child: Text(
                '🔒 Pembayaran aman via Midtrans\nTransfer Bank · QRIS · Virtual Account · GoPay',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: TextStyle(fontSize: 13, color: valueColor, fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  String _countryFlag(String isoCode) {
    if (isoCode.length != 2) return '🌐';
    final base = 0x1F1E6 - 0x41;
    final first = isoCode.toUpperCase().codeUnitAt(0);
    final second = isoCode.toUpperCase().codeUnitAt(1);
    return String.fromCharCode(base + first) + String.fromCharCode(base + second);
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
