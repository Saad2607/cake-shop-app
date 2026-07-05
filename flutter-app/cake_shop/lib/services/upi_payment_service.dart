/// Store UPI ID for receiving payments (demo — replace with real merchant VPA in production).
class UpiConfig {
  static const merchantVpa = 'msaadbjs7@oksbi';
  static const merchantName = 'Sweet Delights';
}

class UpiPaymentService {
  /// Maps internal payment codes to app launch targets.
  static String? appCodeFromMethod(String paymentMethod) {
    if (paymentMethod.startsWith('UPI:')) return null;
    switch (paymentMethod) {
      case 'UPI_PHONEPE':
        return 'PHONEPE';
      case 'UPI_GPAY':
        return 'GPAY';
      case 'UPI_PAYTM':
        return 'PAYTM';
      default:
        return null;
    }
  }

  static Uri buildPaymentUri({
    required double amount,
    required String note,
    String? appCode,
  }) {
    final query = <String, String>{
      'pa': UpiConfig.merchantVpa,
      'pn': UpiConfig.merchantName,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      'tn': note,
    };

    final queryString = query.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final scheme = switch (appCode) {
      'PHONEPE' => 'phonepe://pay',
      'GPAY' => 'tez://upi/pay',
      'PAYTM' => 'paytmmp://pay',
      _ => 'upi://pay',
    };

    return Uri.parse('$scheme?$queryString');
  }

  /// Fallback URIs if the preferred app scheme is not installed.
  static List<Uri> launchCandidates({
    required double amount,
    required String note,
    String? appCode,
  }) {
    final seen = <String>{};
    final uris = <Uri>[];

    void add(String? code) {
      final uri = buildPaymentUri(amount: amount, note: note, appCode: code);
      if (seen.add(uri.toString())) uris.add(uri);
    }

    add(appCode);
    if (appCode != 'GPAY') add('GPAY');
    if (appCode != 'PHONEPE') add('PHONEPE');
    if (appCode != 'PAYTM') add('PAYTM');
    add(null);
    return uris;
  }
}
