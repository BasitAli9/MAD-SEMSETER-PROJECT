class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String getCurrentUserEndpoint = '/auth/me';
  static const String logoutEndpoint = '/auth/logout';

  // Friend Endpoints
  static const String sendFriendRequestEndpoint = '/friends/request';
  static const String getFriendRequestsEndpoint = '/friends/requests';
  static const String acceptFriendRequestEndpoint = '/friends/accept';
  static const String rejectFriendRequestEndpoint = '/friends/reject';
  static const String getFriendsEndpoint = '/friends';
  static const String removeFriendEndpoint = '/friends/remove';
  static const String searchUsersEndpoint = '/friends/search';

  // Conversation Endpoints
  static const String createConversationEndpoint = '/conversations/create';
  static const String getConversationsEndpoint = '/conversations';

  // Message Endpoints
  static const String getMessagesEndpoint = '/messages';
  static const String markAsReadEndpoint = '/messages/read';

  // Full URLs
  static String get loginUrl => baseUrl + loginEndpoint;
  static String get signupUrl => baseUrl + signupEndpoint;
  static String get getCurrentUserUrl => baseUrl + getCurrentUserEndpoint;
  static String get logoutUrl => baseUrl + logoutEndpoint;
  static String get sendFriendRequestUrl => baseUrl + sendFriendRequestEndpoint;
  static String get getFriendRequestsUrl => baseUrl + getFriendRequestsEndpoint;
  static String get getFriendsUrl => baseUrl + getFriendsEndpoint;
  static String get searchUsersUrl => baseUrl + searchUsersEndpoint;
  static String get createConversationUrl => baseUrl + createConversationEndpoint;
  static String get getConversationsUrl => baseUrl + getConversationsEndpoint;

  static String acceptFriendRequestUrl(int requestId) =>
      '$baseUrl$acceptFriendRequestEndpoint/$requestId';

  static String rejectFriendRequestUrl(int requestId) =>
      '$baseUrl$rejectFriendRequestEndpoint/$requestId';

  static String removeFriendUrl(int friendId) =>
      '$baseUrl$removeFriendEndpoint/$friendId';

  static String getMessagesUrl(int conversationId) =>
      '$baseUrl$getMessagesEndpoint/$conversationId';

  static String markAsReadUrl(int conversationId) =>
      '$baseUrl$markAsReadEndpoint/$conversationId';
}