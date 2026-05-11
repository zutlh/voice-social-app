class SeatInfo {
  final int index;
  final String status;
  final int? userId;
  final String userName;
  final String userAvatar;
  final bool micOpen;

  SeatInfo({required this.index, required this.status, this.userId, required this.userName, required this.userAvatar, required this.micOpen});

  factory SeatInfo.fromJson(Map<String, dynamic> json) => SeatInfo(
    index: json['index'] ?? 0,
    status: json['status'] ?? 'FREE',
    userId: json['userId'],
    userName: json['userName'] ?? '',
    userAvatar: json['userAvatar'] ?? '',
    micOpen: json['micOpen'] ?? false,
  );

  bool get isFree => status == 'FREE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isLocked => status == 'LOCKED';
}
