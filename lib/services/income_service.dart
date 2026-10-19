import '../core/format.dart';
import '../models/expense.dart';
import 'refresh.dart';
import 'supabase_client.dart';

class IncomeService {
  /// Total des revenus d'un mois (vue monthly_summary).
  Future<double> monthIncome(DateTime month) async {
    final rows = await supabase
        .from('monthly_summary')
        .select('total_income')
        .eq('month', isoDate(firstOfMonth(month)));
    final list = List<Map<String, dynamic>>.from(rows as List);
    if (list.isEmpty) return 0;
    return (list.first['total_income'] as num).toDouble();
  }

  /// Liste des revenus d'un mois.
  Future<List<Expense>> incomesOfMonth(DateTime month) async {
    final start = firstOfMonth(month);
    final end = addMonths(start, 1);
    final rows = await supabase
        .from('transactions')
        .select('id, wallet_id, category_id, amount, description, '
            'transaction_date, categories(name, color, icon), wallets(name)')
        .eq('type', 'income')
        .gte('transaction_date', isoDate(start))
        .lt('transaction_date', isoDate(end))
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Expense.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  /// Ajoute un salaire (revenu, catégorie Salaire) à la date du jour.
  Future<void> addSalary(double amount) async {
    final cat = await supabase
        .from('categories')
        .select('id')
        .eq('type', 'income')
        .eq('name', 'Salaire')
        .maybeSingle();
    final wallets =
        await supabase.from('wallets').select('id').order('name').limit(1);
    final walletList = List<Map<String, dynamic>>.from(wallets as List);
    if (walletList.isEmpty) {
      throw Exception('Aucun portefeuille trouvé.');
    }
    await supabase.from('transactions').insert({
      'user_id': supabase.auth.currentUser!.id,
      'wallet_id': walletList.first['id'],
      'category_id': cat?['id'],
      'type': 'income',
      'amount': amount,
      'description': 'Salaire',
      'transaction_date': isoDate(DateTime.now()),
    });
    notifyDataChanged();
  }

  Future<void> deleteIncome(String id) async {
    await supabase.from('transactions').delete().eq('id', id);
    notifyDataChanged();
  }
}
