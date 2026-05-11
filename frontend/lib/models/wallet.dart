class Wallet {
  final int balance;
  final int totalRecharged;
  final int totalSpent;

  Wallet({required this.balance, required this.totalRecharged, required this.totalSpent});

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    balance: json['balance'] ?? 0,
    totalRecharged: json['totalRecharged'] ?? 0,
    totalSpent: json['totalSpent'] ?? 0,
  );
}
