class EsimPackage {
  final String packageCode;
  final String supplier; // 'ea' | 'ir' | 'ec'
  final String name;
  final String locationCode;
  final String locationName;
  final double dataGb;       // 0 = unlimited
  final bool unlimited;
  final int durationDays;
  final double priceUsd;
  final int priceIdr;        // harga jual ke customer (IDR)
  final String speed;        // 4G / 5G
  final bool hotspot;
  final bool isPremium;      // badge ⭐

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
  });

  factory EsimPackage.fromJson(Map<String, dynamic> j) {
    final unlimited = j['unlimited'] == true || j['data_gb'] == null || (j['data_gb'] is num && (j['data_gb'] as num) == 0);
    return EsimPackage(
      packageCode: j['package_code'] ?? j['packageCode'] ?? '',
      supplier: j['supplier'] ?? 'ea',
      name: j['name'] ?? '',
      locationCode: j['location_code'] ?? j['locationCode'] ?? '',
      locationName: j['location_name'] ?? j['locationName'] ?? '',
      dataGb: unlimited ? 0 : ((j['data_gb'] ?? 0) as num).toDouble(),
      unlimited: unlimited,
      durationDays: (j['duration_days'] ?? j['duration'] ?? 0) as int,
      priceUsd: ((j['price_usd'] ?? j['price'] ?? 0) as num).toDouble(),
      priceIdr: (j['price_idr'] ?? 0) as int,
      speed: j['speed'] ?? '4G',
      hotspot: j['hotspot'] == true,
      isPremium: j['is_premium'] == true,
    );
  }

  String get dataLabel => unlimited ? 'Unlimited' : '${dataGb % 1 == 0 ? dataGb.toInt() : dataGb} GB';
  String get durationLabel => '$durationDays Hari';
}
