class Wallet {
  final String id;
  final String name;
  final String type;

  const Wallet({required this.id, required this.name, required this.type});

  factory Wallet.fromMap(Map<String, dynamic> m) => Wallet(
        id: m['id'] as String,
        name: m['name'] as String,
        type: m['type'] as String,
      );
}
