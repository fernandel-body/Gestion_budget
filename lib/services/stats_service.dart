import 'package:flutter/material.dart';
import '../core/format.dart';
import 'supabase_client.dart';

class CategoryTotal {
  final String name;
  final Color color;
  final double total;
  const CategoryTotal(this.name, this.color, this.total);
}

class MonthTotal {
  final DateTime month;
  final double total;
  const MonthTotal(this.month, this.total);
}

/// Utilise les vues SQL : monthly_summary et expenses_by_category.
class StatsService {
  /// Total des dépenses d'un mois.
  Future<double> monthTotal(DateTime month) async {
    final rows = await supabase
        .from('monthly_summary')
        .select('total_expense')
        .eq('month', isoDate(firstOfMonth(month)));
    final list = List<Map<String, dynamic>>.from(rows as List);
    if (list.isEmpty) return 0;
    return (list.first['total_expense'] as num).toDouble();
  }

  /// Dépenses par catégorie pour un mois (la plus grosse d'abord).
  Future<List<CategoryTotal>> byCategory(DateTime month) async {
    final rows = await supabase
        .from('expenses_by_category')
        .select('category_name, color, total')
        .eq('month', isoDate(firstOfMonth(month)))
        .order('total', ascending: false);
    return List<Map<String, dynamic>>.from(rows as List)
        .map((r) => CategoryTotal(
              r['category_name'] as String,
              parseColor(r['color'] as String?),
              (r['total'] as num).toDouble(),
            ))
        .toList();
  }

  /// Totaux des [count] derniers mois, se terminant à [endMonth].
  Future<List<MonthTotal>> lastMonths(DateTime endMonth, int count) async {
    final end = firstOfMonth(endMonth);
    final start = addMonths(end, -(count - 1));
    final rows = await supabase
        .from('monthly_summary')
        .select('month, total_expense')
        .gte('month', isoDate(start))
        .lte('month', isoDate(end));
    final byMonth = <String, double>{};
    for (final r in List<Map<String, dynamic>>.from(rows as List)) {
      byMonth[r['month'] as String] = (r['total_expense'] as num).toDouble();
    }
    return List.generate(count, (i) {
      final m = addMonths(start, i);
      return MonthTotal(m, byMonth[isoDate(m)] ?? 0);
    });
  }
}
