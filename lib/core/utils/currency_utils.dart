// lib/core/utils/currency_utils.dart

class CurrencyUtils {
  static const Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '€',
    'INR': '₹',
  };

  static const Map<String, String> names = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'INR': 'Indian Rupee',
  };

  /// Approximate conversion rates relative to USD
  static const Map<String, double> rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'INR': 83.5,
  };

  static String symbol(String code) => symbols[code] ?? '\$';
  static String name(String code)   => names[code] ?? code;

  static String format(double amount, String currency) {
    final sym = symbol(currency);
    if (amount >= 1000000) return '$sym${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000)    return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    return '$sym${amount.toStringAsFixed(2)}';
  }

  static double convert(double amount, String from, String to) {
    final inUSD = amount / (rates[from] ?? 1.0);
    return inUSD * (rates[to] ?? 1.0);
  }
}
