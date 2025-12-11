class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;
  final bool isOnline;
  final String? lastSeen;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.isOnline,
    this.lastSeen,
    required this.createdAt,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      lastSeen: json['last_seen'],
      createdAt: json['created_at'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'is_online': isOnline,
      'last_seen': lastSeen,
      'created_at': createdAt,
    };
  }

  // Copy with
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? profilePicture,
    bool? isOnline,
    String? lastSeen,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}