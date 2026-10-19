import '../models/expense_category.dart';
import '../models/wallet.dart';
import 'supabase_client.dart';

class DataService {
  Future<List<Wallet>> wallets() async {
    final rows =
        await supabase.from('wallets').select('id, name, type').order('name');
    return (rows as List)
        .map((r) => Wallet.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<List<ExpenseCategory>> expenseCategories() async {
    final rows = await supabase
        .from('categories')
        .select('id, name, type, icon, color')
        .eq('type', 'expense')
        .order('name');
    return (rows as List)
        .map(
            (r) => ExpenseCategory.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }
}
