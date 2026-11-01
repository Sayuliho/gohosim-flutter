import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

// Daftar negara — nanti bisa di-fetch dari /locations API
const _countries = [
  {'code': 'JP', 'name': 'Jepang', 'flag': '🇯🇵'},
  {'code': 'KR', 'name': 'Korea Selatan', 'flag': '🇰🇷'},
  {'code': 'MY', 'name': 'Malaysia', 'flag': '🇲🇾'},
  {'code': 'SG', 'name': 'Singapura', 'flag': '🇸🇬'},
  {'code': 'TH', 'name': 'Thailand', 'flag': '🇹🇭'},
  {'code': 'SA', 'name': 'Arab Saudi', 'flag': '🇸🇦'},
  {'code': 'TR', 'name': 'Turki', 'flag': '🇹🇷'},
  {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
  {'code': 'US', 'name': 'Amerika Serikat', 'flag': '🇺🇸'},
  {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
  {'code': 'DE', 'name': 'Jerman', 'flag': '🇩🇪'},
  {'code': 'FR', 'name': 'Prancis', 'flag': '🇫🇷'},
  {'code': 'IT', 'name': 'Italia', 'flag': '🇮🇹'},
  {'code': 'EG', 'name': 'Mesir', 'flag': '🇪🇬'},
  {'code': 'AE', 'name': 'Uni Emirat Arab', 'flag': '🇦🇪'},
  {'code': 'CN', 'name': 'China', 'flag': '🇨🇳'},
  {'code': 'HK', 'name': 'Hong Kong', 'flag': '🇭🇰'},
  {'code': 'TW', 'name': 'Taiwan', 'flag': '🇹🇼'},
  {'code': 'VN', 'name': 'Vietnam', 'flag': '🇻🇳'},
  {'code': 'PH', 'name': 'Filipina', 'flag': '🇵🇭'},
  {'code': 'IN', 'name': 'India', 'flag': '🇮🇳'},
  {'code': 'QA', 'name': 'Qatar', 'flag': '🇶🇦'},
  {'code': 'NL', 'name': 'Belanda', 'flag': '🇳🇱'},
  {'code': 'ES', 'name': 'Spanyol', 'flag': '🇪🇸'},
  {'code': 'RU', 'name': 'Rusia', 'flag': '🇷🇺'},
];

class CountryPickerScreen extends StatefulWidget {
  final String? preselectedCode;
  final String? preselectedName;

  const CountryPickerScreen({super.key, this.preselectedCode, this.preselectedName});

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, String>> _filtered = List.from(_countries);

  @override
  void initState() {
    super.initState();
    // Jika sudah ada preselected, langsung ke packages
    if (widget.preselectedCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/packages/${widget.preselectedCode}?name=${Uri.encodeComponent(widget.preselectedName ?? '')}');
      });
    }
    _searchCtrl.addListener(_filter);
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _countries
          .where((c) =>
              c['name']!.toLowerCase().contains(q) || c['code']!.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Negara')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari negara...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final c = _filtered[i];
                return ListTile(
                  leading: Text(c['flag']!, style: const TextStyle(fontSize: 28)),
                  title: Text(c['name']!),
                  subtitle: Text(c['code']!, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  onTap: () => context.push(
                    '/packages/${c['code']}?name=${Uri.encodeComponent(c['name']!)}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
