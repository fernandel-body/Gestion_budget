import 'package:flutter/material.dart';
import '../services/income_service.dart';
import '../services/refresh.dart';
import 'amount_text.dart';
import 'income_figure.dart';
import 'incomes_sheet.dart';

/// Carte principale du mois : reste à dépenser, salaire et dépensé.
class IncomeCard extends StatefulWidget {
  const IncomeCard({super.key, required this.spent, this.previousSpent = 0});

  /// Dépenses du mois en cours.
  final double spent;

  /// Dépenses du mois précédent (pour la comparaison).
  final double previousSpent;

  @override
  State<IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends State<IncomeCard> {
  final _service = IncomeService();
  late Future<double> _future = _service.monthIncome(DateTime.now());

  static const _coral = Color(0xFFFF8A7A);
  static const _mint = Color(0xFFA9E3BF);

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

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _service.monthIncome(DateTime.now());
    });
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _addSalary() async {
    final ctrl = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter mon salaire'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Montant (Ar)',
            helperText: 'Ex : 500000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(
                  ctrl.text.replaceAll(' ', '').replaceAll(',', '.'));
              if (v == null || v <= 0) return;
              Navigator.pop(ctx, v);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (amount == null) return;
    try {
      await _service.addSalary(amount);
    } catch (_) {
      _snack('Enregistrement impossible. Vérifiez votre connexion.');
    }
  }

  void _showIncomes() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => IncomesSheet(service: _service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final soft = Colors.white.withValues(alpha: 0.78);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: FutureBuilder<double>(
        future: _future,
        builder: (context, snap) {
          final loading = snap.connectionState != ConnectionState.done;
          final income = snap.data ?? 0;
          final hasIncome = income > 0;
          final remaining = income - widget.spent;
          final ratio = hasIncome ? widget.spent / income : 0.0;
          final label = !hasIncome
              ? 'Dépensé ce mois-ci'
              : remaining >= 0
                  ? 'Reste à dépenser'
                  : 'Budget dépassé de';
          final big = !hasIncome ? widget.spent : remaining.abs();
          final diff = widget.previousSpent > 0
              ? (widget.spent - widget.previousSpent) /
                  widget.previousSpent *
                  100
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: soft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                )
              else if (snap.hasError)
                const Text(
                  'Impossible de charger le salaire.',
                  style: TextStyle(color: Colors.white),
                )
              else ...[
                AmountText(
                  big,
                  size: 42,
                  color: Colors.white,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 18),
                if (hasIncome) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio.clamp(0.0, 1.0).toDouble(),
                          child: Container(height: 10, color: _coral),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: IncomeFigure(label: 'Salaire', value: income),
                      ),
                      Expanded(
                        child: IncomeFigure(
                          label: 'Dépensé',
                          value: widget.spent,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    'Ajoutez votre salaire du mois pour savoir combien il vous reste à dépenser.',
                    style: TextStyle(color: soft, fontSize: 14, height: 1.35),
                  ),
                if (diff != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: diff > 0 ? _coral : _mint,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${diff.abs().toStringAsFixed(0)} % '
                          '${diff > 0 ? 'de plus' : 'de moins'} de dépenses que le mois dernier',
                          style: TextStyle(color: soft, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: _addSalary,
                    child: const Text('Ajouter mon salaire'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: _showIncomes,
                    child: const Text('Voir les revenus'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
