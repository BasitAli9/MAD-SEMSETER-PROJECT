import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class SocketProvider with ChangeNotifier {
  bool _isConnected = false;
  String? _socketId;
  Map<int, bool> _onlineUsers = {}; // userId with status isOnline

  bool get isConnected => _isConnected;
  String? get socketId => _socketId;
  Map<int, bool> get onlineUsers => _onlineUsers;

  // Initialize socket connection
  Future<void> initSocket() async {
    await SocketService.connect();
    _setupListeners();
  }

  // Setup socket event listeners
  void _setupListeners() {
    // Connection status
    SocketService.on('connect', (_) {
      _isConnected = true;
      _socketId = SocketService.socket?.id;
      notifyListeners();
      print('Socket Provider: Connected');
    });
    SocketService.on('disconnect', (_) {
      _isConnected = false;
      _socketId = null;
      notifyListeners();
      print('Socket Provider: Disconnected');
    });

    // User status changes
    SocketService.on('user_status_change', (data) {
      final userId = data['userId'];
      final isOnline = data['isOnline'];
      _onlineUsers[userId] = isOnline;
      notifyListeners();
      print('User $userId is now ${isOnline ? "online" : "offline"}');
    });
  }

  // Check if a specific user is online
  bool isUserOnline(int userId) { return _onlineUsers[userId] ?? false; }

  // Disconnect socket
  void disconnect() {
    SocketService.disconnect();
    _isConnected = false;
    _socketId = null;
    _onlineUsers.clear();
    notifyListeners();
  }
}