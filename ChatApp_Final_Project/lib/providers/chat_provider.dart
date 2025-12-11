import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

class ChatProvider with ChangeNotifier {
  List<ConversationModel> _conversations = [];
  Map<int, List<MessageModel>> _messages = {};
  Map<int, bool> _typingStatus = {};
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;

  // Get messages for specific conversation
  List<MessageModel> getMessages(int conversationId) {
    return _messages[conversationId] ?? [];
  }

  // Check if user is typing
  bool isUserTyping(int userId) {
    return _typingStatus[userId] ?? false;
  }

  // Initialize Chat (Setup Socket Listeners)
  void initializeChat(int currentUserId) {
    _setupSocketListeners(currentUserId);
  }

  // Setup Socket Listeners for Real-time Updates
  void _setupSocketListeners(int currentUserId) {
    // Message Sent Confirmation
    SocketService.on('message_sent', (data) {
      final message = MessageModel.fromJson(data);
      _addMessageToConversation(message);
      _updateConversationLastMessage(message);
    });

    // Receive New Message
    SocketService.on('receive_message', (data) {
      final message = MessageModel.fromJson(data);
      _addMessageToConversation(message);
      _updateConversationLastMessage(message);
    });

    // Message Delivered
    SocketService.on('message_delivered', (data) {
      final conversationId = data['conversationId'];
      _updateMessageStatus(conversationId, 'delivered');
    });

    // Messages Read
    SocketService.on('messages_read', (data) {
      final conversationId = data['conversationId'];
      _updateMessageStatus(conversationId, 'read');
    });

    // Typing Indicator
    SocketService.on('user_typing', (data) {
      final userId = data['userId'];
      _typingStatus[userId] = true;
      notifyListeners();
    });

    // Stop Typing
    SocketService.on('user_stop_typing', (data) {
      final userId = data['userId'];
      _typingStatus[userId] = false;
      notifyListeners();
    });
  }

  // Load Conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final result = await ChatService.getConversations();

    if (result['success']) {
      _conversations = result['conversations'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load Messages for Conversation
  Future<void> loadMessages(int conversationId) async {
    final result = await ChatService.getMessages(conversationId);

    if (result['success']) {
      _messages[conversationId] = result['messages'];
      notifyListeners();
    }
  }

  // Send Message via Socket
  void sendMessage({
    required int conversationId,
    required int receiverId,
    required String message,
  }) {
    SocketService.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      message: message,
    );
  }

  // Send Typing Indicator
  void sendTyping(int receiverId, int conversationId) {
    SocketService.sendTypingIndicator(
      receiverId: receiverId,
      conversationId: conversationId,
    );
  }

  // Stop Typing Indicator
  void stopTyping(int receiverId, int conversationId) {
    SocketService.stopTypingIndicator(
      receiverId: receiverId,
      conversationId: conversationId,
    );
  }

  // Mark Messages as Read
  void markAsRead(int conversationId, int senderId) {
    SocketService.markMessageAsRead(
      conversationId: conversationId,
      senderId: senderId,
    );
  }

  // Add message to local state
  void _addMessageToConversation(MessageModel message) {
    if (_messages[message.conversationId] == null) {
      _messages[message.conversationId] = [];
    }

    // Check if message already exists
    final exists = _messages[message.conversationId]!
        .any((m) => m.id == message.id);

    if (!exists) {
      _messages[message.conversationId]!.add(message);
      notifyListeners();
    }
  }

  // Update conversation last message
  void _updateConversationLastMessage(MessageModel message) {
    final index = _conversations.indexWhere(
          (c) => c.conversationId == message.conversationId,
    );

    if (index != -1) {
      // Move to top and update
      final conv = _conversations.removeAt(index);
      _conversations.insert(0, conv);
      notifyListeners();
    }
  }

  // Update message status
  void _updateMessageStatus(int conversationId, String newStatus) {
    if (_messages[conversationId] != null) {
      for (int i = 0; i < _messages[conversationId]!.length; i++) {
        final msg = _messages[conversationId]![i];
        if (msg.status != 'read') {
          _messages[conversationId]![i] = msg.copyWith(status: newStatus);
        }
      }
      notifyListeners();
    }
  }

  // Get or Create Conversation
  Future<int?> getOrCreateConversation(int friendId) async {
    final result = await ChatService.createConversation(friendId);

    if (result['success']) {  return result['conversationId'];}

    return null;
  }
}