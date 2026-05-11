class Room {
  final int id;
  final int ownerId;
  final String ownerName;
  final String ownerAvatar;
  final String name;
  final String cover;
  final String category;
  final int maxUsers;
  final int seatCount;
  final int onlineCount;
  final String status;

  Room({required this.id, required this.ownerId, required this.ownerName, required this.ownerAvatar, required this.name, required this.cover, required this.category, required this.maxUsers, required this.seatCount, required this.onlineCount, required this.status});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'] ?? 0,
    ownerId: json['ownerId'] ?? 0,
    ownerName: json['ownerName'] ?? '',
    ownerAvatar: json['ownerAvatar'] ?? '',
    name: json['name'] ?? '',
    cover: json['cover'] ?? '',
    category: json['category'] ?? 'CHAT',
    maxUsers: json['maxUsers'] ?? 50,
    seatCount: json['seatCount'] ?? 6,
    onlineCount: json['onlineCount'] ?? 0,
    status: json['status'] ?? 'OPEN',
  );
}
