import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../services/refresh.dart';
import '../../services/stats_service.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/month_selector.dart';

class _StatsData {
  final List<CategoryTotal> categories;
  final List<MonthTotal> months;
  const _StatsData(this.categories, this.months);
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _stats = StatsService();
  DateTime _month = firstOfMonth(DateTime.now());
  late Future<_StatsData> _future = _load();

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_reload);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_reload);
    super.dispose();
  }

  Future<_StatsData> _load() async {
    final categories = await _stats.byCategory(_month);
    final months = await _stats.lastMonths(_month, 6);
    return _StatsData(categories, months);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthSelector(
          month: _month,
          onChanged: (m) {
            _month = m;
            _reload();
          },
        ),
        Expanded(
          child: FutureBuilder<_StatsData>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorRetry(message: '${snap.error}', onRetry: _reload);
              }
              final data = snap.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                children: [
                  _buildPie(context, data.categories),
                  const SizedBox(height: 28),
                  _buildBars(context, data.months),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPie(BuildContext context, List<CategoryTotal> cats) {
    final theme = Theme.of(context);
    final total = cats.fold<double>(0, (s, c) => s + c.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Répartition par catégorie', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (cats.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Aucune dépense pour ce mois.')),
          )
        else ...[
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: [
                  for (final c in cats)
                    PieChartSectionData(
                      value: c.total,
                      color: c.color,
                      radius: 60,
                      title: '${(c.total / total * 100).round()}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total : ${formatAr(total)}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final c in cats)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: c.color),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.name)),
                  Text(
                    formatAr(c.total),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBars(BuildContext context, List<MonthTotal> months) {
    final theme = Theme.of(context);
    final maxValue =
        months.fold<double>(0, (m, e) => e.total > m ? e.total : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Évolution sur 6 mois', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue > 0 ? maxValue * 1.2 : 1,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < months.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: months[i].total,
                        color: theme.colorScheme.primary,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                show: true,
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          children: [
                            Text(monthShort(months[i].month),
                                style: const TextStyle(fontSize: 11)),
                            Text(
                              formatCompact(months[i].total),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
