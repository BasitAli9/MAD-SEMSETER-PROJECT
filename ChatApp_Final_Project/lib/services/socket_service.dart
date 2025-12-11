import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/socket_config.dart';
import 'auth_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  // Getters
  static IO.Socket? get socket => _socket;
  static bool get isConnected => _isConnected;

  // Connect to Socket.IO server
  static Future<void> connect() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();

      if (token == null) {
        print('No token found. Cannot connect to socket.');
        return;
      }

      // Disconnect if already connected
      if (_socket != null) {
        disconnect();
      }
      print('Connecting to socket...');

      // Create socket connection
      _socket = IO.io(
        SocketConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use websocket transport
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(SocketConfig.reconnectDelay.inMilliseconds)
            .setReconnectionAttempts(SocketConfig.maxReconnectAttempts)
            .setAuth({'token': token}) // Send JWT token for authentication
            .build(),
      );
      _setupEventListeners();

      // Connect
      _socket!.connect();

    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  // Setup socket event listeners
  static void _setupEventListeners() {
    if (_socket == null) return;

    // Connection successful
    _socket!.on('connect', (_) {
      _isConnected = true;
      print('Socket connected: ${_socket!.id}');
    });

    // Connection error
    _socket!.on('connect_error', (error) {
      _isConnected = false;
      print('Socket connection error: $error');
    });

    // Disconnected
    _socket!.on('disconnect', (_) {
      _isConnected = false;
      print('Socket disconnected');
    });

    // Reconnection attempt
    _socket!.on('reconnect_attempt', (attempt) {
      print('Reconnection attempt: $attempt');
    });

    // Reconnected
    _socket!.on('reconnect', (attempt) {
      _isConnected = true;
      print('Socket reconnected after $attempt attempts');
    });

    // Connected confirmation from server
    _socket!.on('connected', (data) {
      print('Server confirmed connection: $data');
    });
  }

  // Disconnect from socket
  static void disconnect() {
    if (_socket != null) {
      print('Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  // Emit event to server
  static void emit(String event, dynamic data) {
    if (_socket != null && _isConnected)
    {
      _socket!.emit(event, data);
      print(' Emitted event: $event');
    }
    else
      print('Cannot emit. Socket not connected.');
  }

  // Listen to event from server
  static void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      print('Listening to event: $event');
    }
  }

  // Remove event listener
  static void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
      print('Stopped listening to event: $event');
    }
  }

  // Send Message
  static void sendMessage({
    required int conversationId,
    required int receiverId,
    required String message,
  }) {
    emit('send_message', { 'conversationId': conversationId, 'receiverId': receiverId, 'message': message,});
  }

  // Typing Indicator
  static void sendTypingIndicator({ required int receiverId, required int conversationId,}) {
    emit('typing', {
      'receiverId': receiverId,
      'conversationId': conversationId,
    });
  }

  // Stop Typing
  static void stopTypingIndicator({
    required int receiverId,
    required int conversationId,
  }) {
    emit('stop_typing', {'receiverId': receiverId, 'conversationId': conversationId, });
  }

  // Mark Message as Read
  static void markMessageAsRead({ required int conversationId, required int senderId,}) {
    emit('mark_read', {
      'conversationId': conversationId,
      'senderId': senderId,
    });
  }
}