class EsimPackage {
  final String packageCode;
  final String supplier;       // 'ea' | 'ir' | 'ec'
  final String name;
  final String locationCode;
  final String locationName;
  final double dataGb;         // 0 = unlimited
  final bool unlimited;
  final int durationDays;
  final double priceUsd;
  final int priceIdr;          // harga jual ke customer (IDR)
  final String speed;          // 4G / 5G
  final bool hotspot;
  final bool isPremium;        // badge ⭐
  final double dailyQuotaGb;  // kuota per hari untuk unlimited (0 = full unlimited)
  final String coverageType;  // 'single' | 'regional'
  final List<String> supportedCountries; // ISO codes untuk regional bundles
  final bool isHidden;        // paket admin-only, tidak ditampilkan ke customer
  final String fup;           // Fair Use Policy info (opsional)

  EsimPackage({
    required this.packageCode,
    required this.supplier,
    required this.name,
    required this.locationCode,
    required this.locationName,
    required this.dataGb,
    required this.unlimited,
    required this.durationDays,
    required this.priceUsd,
    required this.priceIdr,
    required this.speed,
    required this.hotspot,
    required this.isPremium,
    this.dailyQuotaGb = 0,
    this.coverageType = 'single',
    this.supportedCountries = const [],
    this.isHidden = false,
    this.fup = '',
  });

  factory EsimPackage.fromJson(Map<String, dynamic> j) {
    final unlimited = j['unlimited'] == true || j['data_gb'] == null || (j['data_gb'] is num && (j['data_gb'] as num) == 0);

    // Parse supported_countries
    List<String> countries = [];
    final rawCountries = j['supported_countries'] ?? j['supportedCountries'];
    if (rawCountries is List) {
      countries = rawCountries.map((e) => e.toString()).toList();
    } else if (rawCountries is String && rawCountries.isNotEmpty) {
      countries = rawCountries.split(',').map((e) => e.trim()).toList();
    }

    // Detect coverage type: multi-country jika ada supported_countries > 1 atau location_code mengandung koma
    final locCode = (j['location_code'] ?? j['locationCode'] ?? '') as String;
    String coverageType = (j['coverage_type'] ?? j['coverageType'] ?? 'single') as String;
    if (coverageType == 'single' && (countries.length > 1 || locCode.contains(','))) {
      coverageType = 'regional';
    }

    return EsimPackage(
      packageCode: j['package_code'] ?? j['packageCode'] ?? '',
      supplier: j['supplier'] ?? 'ea',
      name: j['name'] ?? '',
      locationCode: locCode,
      locationName: j['location_name'] ?? j['locationName'] ?? '',
      dataGb: unlimited ? 0 : ((j['data_gb'] ?? 0) as num).toDouble(),
      unlimited: unlimited,
      durationDays: (j['duration_days'] ?? j['duration'] ?? 0) as int,
      priceUsd: ((j['price_usd'] ?? j['price'] ?? 0) as num).toDouble(),
      priceIdr: (j['price_idr'] ?? 0) as int,
      speed: j['speed'] ?? '4G',
      hotspot: j['hotspot'] == true,
      isPremium: j['is_premium'] == true,
      dailyQuotaGb: ((j['daily_quota_gb'] ?? j['dailyQuotaGb'] ?? 0) as num).toDouble(),
      coverageType: coverageType,
      supportedCountries: countries,
      isHidden: j['is_hidden'] == true || j['isHidden'] == true,
      fup: (j['fup'] ?? '') as String,
    );
  }

  String get dataLabel => unlimited ? 'Unlimited' : '${dataGb % 1 == 0 ? dataGb.toInt() : dataGb} GB';
  String get durationLabel => '$durationDays Hari';
  bool get isRegional => coverageType == 'regional' || supportedCountries.length > 1;

  /// Untuk filter ALLOWED_DATA_GB (sama dengan PWA: hanya tampilkan 3,5,10,20,30 GB)
  static final _allowedDataGb = <int>{3, 5, 10, 20, 30};
  bool get isAllowedSize => unlimited || _allowedDataGb.contains(dataGb.round());
}
