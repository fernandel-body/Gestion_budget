class ExpenseCategory {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> m) => ExpenseCategory(
        id: m['id'] as String,
        name: m['name'] as String,
        type: m['type'] as String,
        icon: m['icon'] as String?,
        color: m['color'] as String?,
      );
}
