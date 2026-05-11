class User {
  final int id;
  final String phone;
  final String nickname;
  final String avatar;
  final String gender;

  User({required this.id, required this.phone, required this.nickname, required this.avatar, required this.gender});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? 0,
    phone: json['phone'] ?? '',
    nickname: json['nickname'] ?? '',
    avatar: json['avatar'] ?? '',
    gender: json['gender'] ?? 'UNKNOWN',
  );
}
