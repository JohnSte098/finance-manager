// lib/core/constants/default_categories.dart
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class DefaultCategories {
  static List<CategoryModel> get expenseCategories => [
    CategoryModel(id: 'food',        name: 'Food & Dining',   colorValue: 0xFFF59E0B, iconName: 'food',        isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'transport',   name: 'Transport',       colorValue: 0xFF06B6D4, iconName: 'transport',   isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'shopping',    name: 'Shopping',        colorValue: 0xFFEC4899, iconName: 'shopping',    isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'rent',        name: 'Rent & Housing',  colorValue: 0xFF7C3AED, iconName: 'rent',        isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'health',      name: 'Health',          colorValue: 0xFF10B981, iconName: 'health',      isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'education',   name: 'Education',       colorValue: 0xFF8B5CF6, iconName: 'education',   isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'entertainment',name: 'Entertainment',  colorValue: 0xFFEF4444, iconName: 'entertainment',isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'utilities',   name: 'Utilities',       colorValue: 0xFFF97316, iconName: 'utilities',   isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'travel',      name: 'Travel',          colorValue: 0xFF14B8A6, iconName: 'travel',      isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'personal',    name: 'Personal Care',   colorValue: 0xFF6366F1, iconName: 'personal',    isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'insurance',   name: 'Insurance',       colorValue: 0xFF0EA5E9, iconName: 'insurance',   isCustom: false, isExpenseCategory: true),
    CategoryModel(id: 'other_exp',   name: 'Other',           colorValue: 0xFF64748B, iconName: 'other',       isCustom: false, isExpenseCategory: true),
  ];

  static List<CategoryModel> get incomeCategories => [
    CategoryModel(id: 'salary',      name: 'Salary',          colorValue: 0xFF10B981, iconName: 'salary',      isCustom: false, isExpenseCategory: false),
    CategoryModel(id: 'freelance',   name: 'Freelance',       colorValue: 0xFF7C3AED, iconName: 'freelance',   isCustom: false, isExpenseCategory: false),
    CategoryModel(id: 'investment',  name: 'Investment',      colorValue: 0xFF06B6D4, iconName: 'investment',  isCustom: false, isExpenseCategory: false),
    CategoryModel(id: 'rental',      name: 'Rental Income',   colorValue: 0xFFF59E0B, iconName: 'rental',      isCustom: false, isExpenseCategory: false),
    CategoryModel(id: 'gift',        name: 'Gift / Bonus',    colorValue: 0xFFEC4899, iconName: 'gift',        isCustom: false, isExpenseCategory: false),
    CategoryModel(id: 'other_inc',   name: 'Other Income',    colorValue: 0xFF64748B, iconName: 'other',       isCustom: false, isExpenseCategory: false),
  ];

  static List<CategoryModel> get all => [...expenseCategories, ...incomeCategories];
}

class CategoryIcons {
  static const Map<String, IconData> map = {
    'food':          Icons.restaurant_rounded,
    'transport':     Icons.directions_car_rounded,
    'shopping':      Icons.shopping_bag_rounded,
    'rent':          Icons.home_rounded,
    'health':        Icons.favorite_rounded,
    'education':     Icons.school_rounded,
    'entertainment': Icons.movie_rounded,
    'utilities':     Icons.flash_on_rounded,
    'travel':        Icons.flight_rounded,
    'personal':      Icons.spa_rounded,
    'insurance':     Icons.shield_rounded,
    'salary':        Icons.account_balance_wallet_rounded,
    'freelance':     Icons.laptop_rounded,
    'investment':    Icons.trending_up_rounded,
    'rental':        Icons.villa_rounded,
    'gift':          Icons.card_giftcard_rounded,
    'other':         Icons.more_horiz_rounded,
    // custom fallback
    'custom':        Icons.category_rounded,
    'star':          Icons.star_rounded,
    'heart':         Icons.favorite_border_rounded,
    'bolt':          Icons.bolt_rounded,
    'cart':          Icons.shopping_cart_rounded,
    'music':         Icons.music_note_rounded,
    'pet':           Icons.pets_rounded,
    'sports':        Icons.sports_soccer_rounded,
    'coffee':        Icons.coffee_rounded,
    'game':          Icons.sports_esports_rounded,
    'child':         Icons.child_care_rounded,
    'donation':      Icons.volunteer_activism_rounded,
  };

  static IconData iconFor(String iconName) =>
      map[iconName] ?? Icons.category_rounded;

  /// All selectable icon names for custom category picker
  static List<String> get selectableIcons => [
    'custom', 'star', 'heart', 'bolt', 'cart', 'music', 'pet', 'sports',
    'coffee', 'game', 'child', 'donation', 'food', 'transport', 'shopping',
    'rent', 'health', 'education', 'entertainment', 'utilities', 'travel',
    'personal', 'insurance', 'salary', 'freelance', 'investment', 'gift',
  ];
}
