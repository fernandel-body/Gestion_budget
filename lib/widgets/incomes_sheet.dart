import 'package:flutter/material.dart';
import '../core/format.dart';
import '../models/expense.dart';
import '../services/income_service.dart';
import 'amount_text.dart';

/// Liste des revenus du mois, avec suppression en cas d'erreur de saisie.
class IncomesSheet extends StatefulWidget {
  const IncomesSheet({super.key, required this.service});

  final IncomeService service;

  @override
  State<IncomesSheet> createState() => _IncomesSheetState();
}

class _IncomesSheetState extends State<IncomesSheet> {
  late Future<List<Expense>> _future =
      widget.service.incomesOfMonth(DateTime.now());

  Future<void> _delete(Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce revenu ?'),
        content: Text('${formatAr(e.amount)} le ${formatDate(e.date)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.service.deleteIncome(e.id);
    if (!mounted) return;
    setState(() {
      _future = widget.service.incomesOfMonth(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenus de ${monthLabel(DateTime.now())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: FutureBuilder<List<Expense>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return const Text('Impossible de charger les revenus.');
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aucun revenu ce mois-ci. Appuyez sur Ajouter mon salaire.',
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.payments_outlined, color: primary),
                        title:
                            Text(e.description ?? e.categoryName ?? 'Revenu'),
                        subtitle: Text(formatDate(e.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AmountText(e.amount,
                                size: 15, color: primary, sign: '+'),
                            IconButton(
                              tooltip: 'Supprimer',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(e),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
