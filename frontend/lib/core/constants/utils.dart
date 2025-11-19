import 'package:flutter/material.dart';

/// Strengthens (brightens or darkens) a color using a factor.
/// factor > 1.0  → brighten
/// factor < 1.0  → darken
Color strengthenColor(Color color, double factor) {
  int r = ((color.r * 255.0) * factor).round().clamp(0, 255);
  int g = ((color.g * 255.0) * factor).round().clamp(0, 255);
  int b = ((color.b * 255.0) * factor).round().clamp(0, 255);
  int a = ((color.a * 255.0)).round().clamp(0, 255);

  return Color.fromARGB(a, r, g, b);
}

/// Generates the 7 dates for a given week.
/// weekOffset = 0 → this week
/// weekOffset = 1 → next week
/// weekOffset = -1 → previous week
List<DateTime> generateWeekDates(int weekOffset) {
  final today = DateTime.now();

  // Monday = 1, Sunday = 7
  DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  startOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));

  return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
}

/// Converts a Color to a hex string: #rrggbb
String rgbToHex(Color color) {
  int r = (color.r * 255.0).round();
  int g = (color.g * 255.0).round();
  int b = (color.b * 255.0).round();

  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

/// Converts a hex string (rrggbb or #rrggbb) into a Color.
/// Automatically makes it fully opaque (FF).
Color hexToRgb(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}
