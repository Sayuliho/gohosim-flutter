import 'package_model.dart';

class Bundle {
  final String locationCode;
  final String bundleName;
  final int countryCount;
  final String supportedCountries; // e.g. "JP, KR" or "CN, JP, KR"
  final List<EsimPackage> packages;

  const Bundle({
    required this.locationCode,
    required this.bundleName,
    required this.countryCount,
    required this.supportedCountries,
    required this.packages,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    final pkgList = (json['packages'] as List? ?? [])
        .map((j) => EsimPackage.fromJson(j as Map<String, dynamic>))
        .where((p) => p.isVisible)
        .toList();

    return Bundle(
      locationCode: json['location_code'] as String? ?? '',
      bundleName: json['bundle_name'] as String? ?? '',
      countryCount: (json['country_count'] as num?)?.toInt() ?? 0,
      supportedCountries: json['supported_countries'] as String? ?? '',
      packages: pkgList,
    );
  }

  /// Parse "JP, KR, CN" → ['JP', 'KR', 'CN']
  List<String> get countryCodes => supportedCountries
      .split(',')
      .map((s) => s.trim().toUpperCase())
      .where((s) => s.length == 2)
      .toList();
}
