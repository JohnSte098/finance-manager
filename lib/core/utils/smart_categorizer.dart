// lib/core/utils/smart_categorizer.dart

/// Keyword-based smart categorization
class SmartCategorizer {
  static const Map<String, List<String>> _rules = {
    'food':          ['food', 'restaurant', 'cafe', 'pizza', 'burger', 'sushi', 'dinner', 'lunch', 'breakfast', 'coffee', 'bakery', 'mcdonalds', 'kfc', 'dominos', 'zomato', 'swiggy'],
    'transport':     ['uber', 'ola', 'taxi', 'bus', 'metro', 'petrol', 'fuel', 'parking', 'toll', 'rapido', 'lyft', 'cab'],
    'shopping':      ['amazon', 'flipkart', 'shopping', 'mall', 'store', 'buy', 'myntra', 'nykaa', 'meesho', 'clothes'],
    'rent':          ['rent', 'lease', 'housing', 'apartment', 'flat', 'mortgage'],
    'health':        ['doctor', 'hospital', 'medicine', 'pharmacy', 'pharmacy', 'gym', 'clinic', 'health', 'wellness'],
    'entertainment': ['netflix', 'spotify', 'youtube', 'movie', 'theatre', 'concert', 'game', 'prime', 'disney', 'hotstar'],
    'utilities':     ['electricity', 'water', 'internet', 'wifi', 'bill', 'gas', 'phone', 'recharge', 'airtel', 'jio', 'bsnl'],
    'travel':        ['flight', 'hotel', 'booking', 'airbnb', 'train', 'irctc', 'bus ticket', 'holiday', 'vacation', 'trip'],
    'education':     ['school', 'college', 'course', 'tuition', 'book', 'udemy', 'coursera', 'fees'],
    'salary':        ['salary', 'wage', 'paycheck', 'pay day', 'stipend', 'income'],
    'freelance':     ['freelance', 'project payment', 'client', 'invoice', 'gig'],
    'investment':    ['stock', 'mutual fund', 'dividend', 'interest', 'returns', 'sip', 'crypto'],
  };

  /// Returns the matching categoryId or null if no match
  static String? suggest(String input) {
    final lower = input.toLowerCase();
    for (final entry in _rules.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return null;
  }
}
