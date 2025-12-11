class SocketConfig
{
  static const String socketUrl = 'http://localhost:3000';
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration reconnectDelay = Duration(seconds: 2);
  static const int maxReconnectAttempts = 5;
}