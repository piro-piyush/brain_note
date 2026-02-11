class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileUrl;
  final String token;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileUrl,
    required this.token,
  });

  /* ---------- fromJson ---------- */
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      token: json['token'] ?? '',
    );
  }

  /* ---------- toJson ---------- */
  Map<String, dynamic> toJson() {
    return {
      '_id': uid,
      'name': name,
      'email': email,
      'profileUrl': profileUrl,
      'token': token,
    };
  }

  /* ---------- copyWith ---------- */
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileUrl,
    String? token,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileUrl: profileUrl ?? this.profileUrl,
      token: token ?? this.token,
    );
  }
}
