class Expense {
  final String id;
  final String walletId;
  final String? categoryId;
  final double amount;
  final String? description;
  final DateTime date;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final String? walletName;

  const Expense({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.date,
    this.categoryId,
    this.description,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.walletName,
  });

  factory Expense.fromMap(Map<String, dynamic> m) {
    final cat = m['categories'] as Map<String, dynamic>?;
    final wal = m['wallets'] as Map<String, dynamic>?;
    return Expense(
      id: m['id'] as String,
      walletId: m['wallet_id'] as String,
      categoryId: m['category_id'] as String?,
      amount: (m['amount'] as num).toDouble(),
      description: m['description'] as String?,
      date: DateTime.parse(m['transaction_date'] as String),
      categoryName: cat?['name'] as String?,
      categoryColor: cat?['color'] as String?,
      categoryIcon: cat?['icon'] as String?,
      walletName: wal?['name'] as String?,
    );
  }
}
