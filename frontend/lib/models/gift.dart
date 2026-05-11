class Gift {
  final int id;
  final String name;
  final String icon;
  final int price;
  final String type;

  Gift({required this.id, required this.name, required this.icon, required this.price, required this.type});

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    icon: json['icon'] ?? '',
    price: json['price'] ?? 0,
    type: json['type'] ?? 'NORMAL',
  );
}
