import 'package:flutter/material.dart';

class Promotion {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final String route;

  Promotion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.route,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      backgroundColor: Color(json['backgroundColor'] as int),
      route: json['route'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon': icon.codePoint,
      'backgroundColor': backgroundColor.value,
      'route': route,
    };
  }
}
