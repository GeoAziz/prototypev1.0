import 'package:flutter/material.dart';

IconData getCategoryIcon(String iconName) {
  switch (iconName) {
    case 'home':
      return Icons.home;
    case 'build':
      return Icons.build;
    case 'star':
      return Icons.star;
    default:
      return Icons.category;
  }
}
