import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../services/data_service.dart';
import '../../services/expense_service.dart';
import '../../services/refresh.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/month_selector.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _service = ExpenseService();
  final _data = DataService();

  DateTime _month = firstOfMonth(DateTime.now());
  List<Expense> _all = [];
  List<ExpenseCategory> _categories = [];
  String _query = '';
  String? _categoryFilter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    dataVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final expenses = await _service.byMonth(_month);
      if (_categories.isEmpty) {
        _categories = await _data.expenseCategories();
      }
      if (!mounted) return;
      setState(() {
        _all = expenses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<Expense> get _filtered {
    final q = _query.trim().toLowerCase();
    return _all.where((e) {
      if (_categoryFilter != null && e.categoryId != _categoryFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final text =
          '${e.description ?? ''} ${e.categoryName ?? ''} ${e.walletName ?? ''}'
              .toLowerCase();
      return text.contains(q);
    }).toList();
  }

  Future<void> _edit(Expense e) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: e)),
    );
  }

  Future<void> _delete(Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette dépense ?'),
        content: Text('${formatAr(e.amount)} • ${formatDate(e.date)}'),
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
    try {
      await _service.delete(e.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suppression impossible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final total = items.fold<double>(0, (sum, e) => sum + e.amount);

    return Column(
      children: [
        MonthSelector(
          month: _month,
          onChanged: (m) {
            _month = m;
            _load();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une dépense...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Toutes'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                ),
              ),
              ..._categories.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: _categoryFilter == c.id,
                    onSelected: (_) => setState(() => _categoryFilter = c.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${items.length} dépense(s)'),
              Text(
                'Total : ${formatAr(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ErrorRetry(message: _error!, onRetry: _load)
                  : items.isEmpty
                      ? const Center(
                          child: Text('Aucune dépense pour cette période.'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) => ExpenseTile(
                            expense: items[i],
                            onTap: () => _edit(items[i]),
                            onDelete: () => _delete(items[i]),
                          ),
                        ),
        ),
      ],
    );
  }
}
