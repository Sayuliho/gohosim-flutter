import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/package_model.dart';

class PackagesProvider extends ChangeNotifier {
  List<EsimPackage> _packages = [];
  List<EsimPackage> _bundles = [];
  bool _loading = false;
  bool _loadingBundles = false;
  String? _error;
  String? _bundlesError;
  String? _lastCountry;

  List<EsimPackage> get packages => _packages;
  List<EsimPackage> get bundles => _bundles;
  bool get loading => _loading;
  bool get loadingBundles => _loadingBundles;
  String? get error => _error;
  String? get bundlesError => _bundlesError;

  Future<void> fetchPackages(String countryCode) async {
    if (_lastCountry == countryCode && _packages.isNotEmpty) return; // cache sederhana
    _loading = true;
    _error = null;
    notifyListeners();

    final res = await ApiClient.get('/packages?country=$countryCode');
    if (res['ok'] == true || res['packages'] != null) {
      final list = (res['packages'] as List? ?? []);
      _packages = list
          .map((j) => EsimPackage.fromJson(j as Map<String, dynamic>))
          .where((p) => !p.isHidden && p.durationDays >= 3) // sama dengan PWA filter
          .toList();
      _lastCountry = countryCode;

      // Fetch regional bundles secara paralel (background, seperti PWA)
      _fetchBundles(countryCode);
    } else {
      _error = res['error'] ?? 'Gagal memuat paket';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _fetchBundles(String countryCode) async {
    _loadingBundles = true;
    _bundlesError = null;
    notifyListeners();

    final res = await ApiClient.get('/packages/bundles?country=$countryCode');
    if (res['ok'] == true || res['bundles'] != null) {
      final list = (res['bundles'] as List? ?? []);
      _bundles = list
          .map((j) => EsimPackage.fromJson(j as Map<String, dynamic>))
          .where((p) => !p.isHidden)
          .toList();
    } else {
      _bundlesError = res['error'];
      _bundles = [];
    }
    _loadingBundles = false;
    notifyListeners();
  }

  void clear() {
    _packages = [];
    _bundles = [];
    _lastCountry = null;
    notifyListeners();
  }
}
