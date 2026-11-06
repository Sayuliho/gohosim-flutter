const _countryNames = {
  'JP': 'Japan', 'SG': 'Singapore', 'MY': 'Malaysia', 'TH': 'Thailand',
  'ID': 'Indonesia', 'PH': 'Philippines', 'VN': 'Vietnam', 'KR': 'South Korea',
  'CN': 'China', 'HK': 'Hong Kong', 'TW': 'Taiwan', 'IN': 'India',
  'AU': 'Australia', 'NZ': 'New Zealand', 'US': 'United States', 'GB': 'United Kingdom',
  'DE': 'Germany', 'FR': 'France', 'IT': 'Italy', 'ES': 'Spain',
  'NL': 'Netherlands', 'CH': 'Switzerland', 'AT': 'Austria', 'BE': 'Belgium',
  'SE': 'Sweden', 'NO': 'Norway', 'DK': 'Denmark', 'FI': 'Finland',
  'PT': 'Portugal', 'PL': 'Poland', 'CZ': 'Czech Republic', 'TR': 'Turkey',
  'AE': 'UAE', 'SA': 'Saudi Arabia', 'EG': 'Egypt', 'ZA': 'South Africa',
  'BR': 'Brazil', 'MX': 'Mexico', 'AR': 'Argentina', 'CL': 'Chile',
  'CA': 'Canada', 'RU': 'Russia', 'UA': 'Ukraine', 'GR': 'Greece',
  'MM': 'Myanmar', 'KH': 'Cambodia', 'LA': 'Laos', 'BD': 'Bangladesh',
  'PK': 'Pakistan', 'LK': 'Sri Lanka', 'NP': 'Nepal', 'MO': 'Macau',
  'BN': 'Brunei', 'MN': 'Mongolia', 'KZ': 'Kazakhstan', 'UZ': 'Uzbekistan',
};

class Order {
  final String orderRef;
  final String supplier;
  final String packageCode;
  final String country;
  final String? countryName;
  final String customerName;
  final String? customerEmail;
  final String customerWa;
  final double dataGb;
  final int durationDays;
  final int priceIdr;
  final double priceUsd;
  final int? totalIdr;
  final String status;
  final String? qrCodeUrl;
  final String? activationCode;
  final String? iccid;
  final String? esimTranNo;
  final String? snapToken;
  final DateTime createdAt;

  Order({
    required this.orderRef,
    required this.supplier,
    required this.packageCode,
    required this.country,
    this.countryName,
    required this.customerName,
    this.customerEmail,
    required this.customerWa,
    required this.dataGb,
    required this.durationDays,
    required this.priceIdr,
    required this.priceUsd,
    this.totalIdr,
    required this.status,
    this.qrCodeUrl,
    this.activationCode,
    this.iccid,
    this.esimTranNo,
    this.snapToken,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        orderRef: j['order_ref'] ?? '',
        supplier: j['supplier'] ?? '',
        packageCode: j['package_code'] ?? '',
        country: j['country'] ?? '',
        countryName: j['country_name'],
        customerName: j['customer_name'] ?? '',
        customerEmail: j['customer_email'],
        customerWa: j['customer_wa'] ?? '',
        dataGb: ((j['data_gb'] ?? 0) as num).toDouble(),
        durationDays: (j['duration_days'] ?? 0) as int,
        priceIdr: (j['price_idr'] ?? 0) as int,
        priceUsd: ((j['price_usd'] ?? 0) as num).toDouble(),
        totalIdr: j['total_idr'] != null ? (j['total_idr'] as num).toInt() : null,
        status: j['status'] ?? 'pending',
        qrCodeUrl: j['qr_code_url'],
        activationCode: j['activation_code'],
        iccid: j['iccid'],
        esimTranNo: j['esim_tran_no'],
        snapToken: j['snap_token'],
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );

  /// Human-readable country name, e.g. "Japan", "Singapore"
  String get countryDisplayName =>
      countryName ?? _countryNames[country.toUpperCase()] ?? country;

  bool get isActive    => status == 'active';
  bool get isPending   => status == 'pending' || status == 'pending_payment';
  bool get isExpired   => status == 'expired';

  String get dataLabel {
    if (dataGb <= 0) return 'Unlimited';
    final v = dataGb % 1 == 0 ? dataGb.toInt().toString() : dataGb.toString();
    return '$v GB';
  }

  String get durationLabel => '$durationDays Hari';
}

// Backward-compat alias
typedef OrderModel = Order;
