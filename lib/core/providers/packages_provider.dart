import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/package_model.dart';

class PackagesProvider extends ChangeNotifier {
  List<EsimPackage> _packages = [];
  bool _loading = false;
  String? _error;
  String? _lastCountry;

  List<EsimPackage> get packages => _packages;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchPackages(String countryCode) async {
    if (_lastCountry == countryCode && _packages.isNotEmpty) return; // cache sederhana
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await ApiClient.get('/packages?country=$countryCode');
    if (res['ok'] == true || res['packages'] != null) {
      final list = (res['packages'] as List? ?? []);
      _packages = list.map((j) => EsimPackage.fromJson(j as Map<String, dynamic>)).toList();
      _lastCountry = countryCode;
    } else {
      _error = res['error'] ?? 'Gagal memuat paket';
    }
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _packages = [];
    _lastCountry = null;
    notifyListeners();
  }
}
