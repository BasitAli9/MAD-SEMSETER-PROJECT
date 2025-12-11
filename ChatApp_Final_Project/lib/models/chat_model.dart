class ConversationModel {
  final int conversationId;
  final int friendId;
  final String friendName;
  final String friendEmail;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? profilePicture;

  ConversationModel({
    required this.conversationId,
    required this.friendId,
    required this.friendName,
    required this.friendEmail,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.profilePicture,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversation_id'] is int
          ? json['conversation_id']
          : int.parse(json['conversation_id'].toString()),
      friendId: json['friend_id'] is int
          ? json['friend_id']
          : int.parse(json['friend_id'].toString()),
      friendName: json['friend_name'] ?? '',
      friendEmail: json['friend_email'] ?? '',
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.parse(json['unread_count']?.toString() ?? '0'),
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      profilePicture: json['profile_picture'],
    );
  }
}