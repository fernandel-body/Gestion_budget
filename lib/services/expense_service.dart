import '../core/format.dart';
import '../models/expense.dart';
import 'refresh.dart';
import 'supabase_client.dart';

const _select =
    'id, wallet_id, category_id, type, amount, description, transaction_date, '
    'categories(name, color, icon), wallets(name)';

class ExpenseService {
  List<Expense> _parse(dynamic rows) => (rows as List)
      .map((r) => Expense.fromMap(Map<String, dynamic>.from(r as Map)))
      .toList();

  /// Dépenses d'un mois donné, les plus récentes d'abord.
  Future<List<Expense>> byMonth(DateTime month) async {
    final start = firstOfMonth(month);
    final end = addMonths(start, 1);
    final rows = await supabase
        .from('transactions')
        .select(_select)
        .eq('type', 'expense')
        .gte('transaction_date', isoDate(start))
        .lt('transaction_date', isoDate(end))
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false);
    return _parse(rows);
  }

  /// Dernières dépenses (tous mois confondus).
  Future<List<Expense>> latest(int limit) async {
    final rows = await supabase
        .from('transactions')
        .select(_select)
        .eq('type', 'expense')
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);
    return _parse(rows);
  }

  Future<void> add({
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    await supabase.from('transactions').insert({
      'user_id': supabase.auth.currentUser!.id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': 'expense',
      'amount': amount,
      'description': description,
      'transaction_date': isoDate(date),
    });
    notifyDataChanged();
  }

  Future<void> update(
    String id, {
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    await supabase.from('transactions').update({
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'transaction_date': isoDate(date),
    }).eq('id', id);
    notifyDataChanged();
  }

  Future<void> delete(String id) async {
    await supabase.from('transactions').delete().eq('id', id);
    notifyDataChanged();
  }
}
