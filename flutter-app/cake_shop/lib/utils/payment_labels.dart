class PaymentLabels {
  static String format(String method) {
    if (method == 'COD') return 'Cash on Delivery';
    if (method == 'CARD') return 'Debit / Credit Card';
    if (method.startsWith('UPI:')) {
      return 'UPI · ${method.substring(4)}';
    }
    switch (method) {
      case 'UPI_PHONEPE':
        return 'UPI · PhonePe';
      case 'UPI_GPAY':
        return 'UPI · Google Pay';
      case 'UPI_PAYTM':
        return 'UPI · Paytm';
      case 'UPI':
        return 'UPI';
      case 'MOCK_CARD':
        return 'Debit / Credit Card';
      default:
        return method.replaceAll('_', ' ');
    }
  }

  static bool requiresOnlinePayment(String method) {
    return method != 'COD';
  }

  static String? upiAppName(String method) {
    switch (method) {
      case 'UPI_PHONEPE':
        return 'PhonePe';
      case 'UPI_GPAY':
        return 'Google Pay';
      case 'UPI_PAYTM':
        return 'Paytm';
      default:
        return null;
    }
  }
}
