import 'package:flutter/material.dart';

const _moisCourts = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.'
];

const _moisLongs = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre'
];

/// 12500 -> "12 500 Ar"
String formatAr(num value) {
  final negative = value < 0;
  final s = value.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${negative ? '-' : ''}$buf Ar';
}

/// 12500 -> "12k" (pour les petits espaces)
String formatCompact(num value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).round()}k';
  return value.round().toString();
}

String formatDate(DateTime d) =>
    '${d.day} ${_moisCourts[d.month - 1]} ${d.year}';

String monthLabel(DateTime m) => '${_moisLongs[m.month - 1]} ${m.year}';

String monthShort(DateTime m) => _moisCourts[m.month - 1];

DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime addMonths(DateTime m, int n) => DateTime(m.year, m.month + n, 1);

/// DateTime -> "2026-10-08" (format attendu par PostgreSQL)
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Color parseColor(String? hex, {Color fallback = Colors.grey}) {
  if (hex == null || hex.isEmpty) return fallback;
  final h = hex.replaceAll('#', '');
  final value = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return value == null ? fallback : Color(value);
}

IconData iconFromName(String? name) {
  switch (name) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'school':
      return Icons.school;
    case 'phone_android':
      return Icons.phone_android;
    case 'home':
      return Icons.home;
    case 'favorite':
      return Icons.favorite;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'bolt':
      return Icons.bolt;
    case 'more_horiz':
      return Icons.more_horiz;
    case 'payments':
      return Icons.payments;
    case 'savings':
      return Icons.savings;
    case 'add_circle':
      return Icons.add_circle;
    default:
      return Icons.category;
  }
}
