class FriendRequestModel {
  final int requestId;
  final int userId;
  final String name;
  final String email;
  final String? profilePicture;
  final bool isOnline;
  final String createdAt;

  FriendRequestModel({
    required this.requestId,
    required this.userId,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.isOnline,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['request_id'] is int
          ? json['request_id']
          : int.parse(json['request_id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}