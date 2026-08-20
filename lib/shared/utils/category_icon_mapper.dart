import 'package:flutter/material.dart';

IconData categoryIconFromKey(String icon) {
  switch (icon) {
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'receipt_long':
      return Icons.receipt_long_rounded;
    case 'shopping_cart':
      return Icons.shopping_cart_rounded;
    case 'movie':
      return Icons.movie_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'payments':
      return Icons.payments_rounded;
    case 'emoji_events':
      return Icons.emoji_events_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'swap_horiz':
      return Icons.swap_horiz_rounded;
    case 'local_offer':
      return Icons.local_offer_rounded;
    case 'shopping_bag':
      return Icons.shopping_bag_rounded;
    case 'card_giftcard':
      return Icons.card_giftcard_rounded;
    case 'health_and_safety':
      return Icons.health_and_safety_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'trending_up':
      return Icons.trending_up_rounded;
    default:
      return Icons.category_rounded;
  }
}