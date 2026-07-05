import 'package:intl/intl.dart';

/// Formats amounts in Indian Rupees (₹).
/// Backend prices are stored in INR.
class CurrencyFormatter {
  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amountInr) => _inr.format(amountInr);
}
