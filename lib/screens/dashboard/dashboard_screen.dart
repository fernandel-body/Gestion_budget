import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import '../../services/refresh.dart';
import '../../services/stats_service.dart';
import '../../services/supabase_client.dart';
import '../../widgets/amount_text.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/income_card.dart';

class _DashData {
  final double current;
  final double previous;
  final List<CategoryTotal> categories;
  final List<Expense> latest;
  const _DashData(this.current, this.previous, this.categories, this.latest);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onSeeAll});

  /// Appelé quand l'utilisateur veut voir toutes les dépenses.
  final VoidCallback onSeeAll;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _stats = StatsService();
  final _expenses = ExpenseService();
  late Future<_DashData> _future = _load();

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

  Future<_DashData> _load() async {
    final now = firstOfMonth(DateTime.now());
    final current = await _stats.monthTotal(now);
    final previous = await _stats.monthTotal(addMonths(now, -1));
    final categories = await _stats.byCategory(now);
    final latest = await _expenses.latest(5);
    return _DashData(current, previous, categories, latest);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        supabase.auth.currentUser?.userMetadata?['full_name'] as String?;
    final hasName = name != null && name.isNotEmpty;

    return FutureBuilder<_DashData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return ErrorRetry(message: '${snap.error}', onRetry: _reload);
        }
        final d = snap.data!;

        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            try {
              await _future;
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              Text(
                hasName ? 'Bonjour, $name' : 'Bonjour',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(monthLabel(DateTime.now()),
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              IncomeCard(spent: d.current, previousSpent: d.previous),
              const SizedBox(height: 28),
              Text('Par catégorie', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              if (d.categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Aucune dépense ce mois-ci. Appuyez sur Dépense pour ajouter la première.',
                  ),
                )
              else
                ...d.categories.take(5).map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                AmountText(c.total, size: 15),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: d.current > 0 ? c.total / d.current : 0,
                              color: c.color,
                              backgroundColor: theme.colorScheme.outline,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dernières dépenses',
                      style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: widget.onSeeAll,
                    child: const Text('Tout voir'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (d.latest.isEmpty)
                const Text('Aucune dépense enregistrée.')
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (var i = 0; i < d.latest.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ExpenseTile(expense: d.latest[i]),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
