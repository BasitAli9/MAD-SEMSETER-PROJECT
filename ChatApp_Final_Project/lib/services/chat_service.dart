import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'auth_service.dart';

class ChatService
{
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create or Get Conversation
  static Future<Map<String, dynamic>> createConversation(int friendId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.createConversationUrl),
        headers: headers,
        body: jsonEncode({'friendId': friendId}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return { 'success': true,  'conversationId': data['conversation']['id'], };
      }
      else
      {
        return { 'success': false,  'message': data['message'] ?? 'Failed to create conversation', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Get All Conversations
  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getConversationsUrl),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final conversations = (data['conversations'] as List)
            .map((json) => ConversationModel.fromJson(json))
            .toList();

        return { 'success': true, 'conversations': conversations, };
      }
      else
      {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get conversations',
          'conversations': <ConversationModel>[],
        };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', 'conversations': <ConversationModel>[],};
    }
  }

  // Get Messages
  static Future<Map<String, dynamic>> getMessages(
      int conversationId, {
        int limit = 50,
        int offset = 0,
      }) async
  {
    try
    {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.getMessagesUrl(conversationId)}?limit=$limit&offset=$offset',
        ),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final messages = (data['messages'] as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();

        return { 'success': true, 'messages': messages, };
      }
      else
      {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get messages',
          'messages': <MessageModel>[],
        };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', 'messages': <MessageModel>[], };
    }
  }

  // Mark Messages as Read
  static Future<Map<String, dynamic>> markAsRead(int conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(ApiConfig.markAsReadUrl(conversationId)),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      return { 'success': data['success'] == true, 'message': data['message'],};
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }
}