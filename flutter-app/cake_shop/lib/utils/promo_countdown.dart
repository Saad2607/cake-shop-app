/// Countdown text for limited-time offers.
class PromoCountdown {
  static String label(DateTime expiresAt) {
    final now = DateTime.now();
    if (!expiresAt.isAfter(now)) return 'Offer ended';

    final diff = expiresAt.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;

    if (days >= 2) return 'Ends in $days days';
    if (days == 1) return 'Ends in 1 day ${hours}h';
    if (diff.inHours >= 1) return 'Ends in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'Ends in ${diff.inMinutes}m';
  }

  static bool isActive(DateTime? expiresAt) {
    if (expiresAt == null) return true;
    return expiresAt.isAfter(DateTime.now());
  }
}
