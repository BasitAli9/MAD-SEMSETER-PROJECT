import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/friend_request_model.dart';
import 'auth_service.dart';

class FriendService
{
  // Get authorization header
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Send Friend Request
  static Future<Map<String, dynamic>> sendFriendRequest(int friendId) async
  {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.sendFriendRequestUrl),
        headers: headers,
        body: jsonEncode({'friendId': friendId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return { 'success': true,  'message': data['message'], };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to send request', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Get Friend Requests
  static Future<Map<String, dynamic>> getFriendRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getFriendRequestsUrl),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final requests = (data['requests'] as List)
            .map((json) => FriendRequestModel.fromJson(json))
            .toList();

        return {'success': true, 'requests': requests, };
      }
      else
      {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get requests',
          'requests': <FriendRequestModel>[],
        };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', 'requests': <FriendRequestModel>[], };
    }
  }

  // Accept Friend Request
  static Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(ApiConfig.acceptFriendRequestUrl(requestId)),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true)
      {
        return { 'success': true, 'message': data['message'],};
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to accept request', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Reject Friend Request
  static Future<Map<String, dynamic>> rejectFriendRequest(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.rejectFriendRequestUrl(requestId)),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true)
      {
        return { 'success': true, 'message': data['message'], };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to reject request', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Get Friends List
  static Future<Map<String, dynamic>> getFriends() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getFriendsUrl),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final friends = (data['friends'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();

        return { 'success': true, 'friends': friends, };
      }
      else
      {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get friends',
          'friends': <UserModel>[],
        };
      }
    }
    catch (e)
    {
      return { 'success': false,  'message': 'Connection error', 'friends': <UserModel>[],};
    }
  }

  // Remove Friend
  static Future<Map<String, dynamic>> removeFriend(int friendId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.removeFriendUrl(friendId)),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
      {
        return {'success': true,  'message': data['message'], };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to remove friend', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Search Users
  static Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.searchUsersUrl}?query=$query'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final users = (data['users'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();

        return { 'success': true, 'users': users, };
      }
      else
      {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to search users',
          'users': <UserModel>[],
        };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', 'users': <UserModel>[], };
    }
  }

  // Get Friend Request Count
  static Future<int> getFriendRequestCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/friends/requests/count'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
      {
        return data['count'] ?? 0;
      }
      return 0;
    }
    catch (e)
    {
      return 0;
    }
  }
}