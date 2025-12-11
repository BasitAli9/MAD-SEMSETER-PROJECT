import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/friend_request_model.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  List<UserModel> _friends = [];
  List<FriendRequestModel> _friendRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _requestCount = 0;

  List<UserModel> get friends => _friends;
  List<FriendRequestModel> get friendRequests => _friendRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get requestCount => _requestCount;

  // Load Friends
  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    final result = await FriendService.getFriends();

    if (result['success'])
    {
      _friends = result['friends'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load Friend Requests
  Future<void> loadFriendRequests() async {
    final result = await FriendService.getFriendRequests();

    if (result['success']) {
      _friendRequests = result['requests'];
      _requestCount = _friendRequests.length;
      notifyListeners();
    }
  }

  // Load Request Count Only
  Future<void> loadRequestCount() async {
    _requestCount = await FriendService.getFriendRequestCount();
    notifyListeners();
  }

  // Send Friend Request
  Future<Map<String, dynamic>> sendFriendRequest(int friendId) async {
    final result = await FriendService.sendFriendRequest(friendId);

    if (result['success'])
    {
      // Remove from search results
      _searchResults.removeWhere((user) => user.id == friendId);
      notifyListeners();
    }
    return result;
  }

  // Accept Friend Request
  Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    final result = await FriendService.acceptFriendRequest(requestId);

    if (result['success']) {
      // Remove from requests and reload friends
      _friendRequests.removeWhere((req) => req.requestId == requestId);
      await loadFriends();
    }

    return result;
  }

  // Reject Friend Request
  Future<Map<String, dynamic>> rejectFriendRequest(int requestId) async {
    final result = await FriendService.rejectFriendRequest(requestId);

    if (result['success']) {
      _friendRequests.removeWhere((req) => req.requestId == requestId);
      notifyListeners();
    }

    return result;
  }

  // Remove Friend
  Future<Map<String, dynamic>> removeFriend(int friendId) async {
    final result = await FriendService.removeFriend(friendId);

    if (result['success']) {
      _friends.removeWhere((friend) => friend.id == friendId);
      notifyListeners();
    }

    return result;
  }

  // Search Users


  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
  Future<void> searchUsers(String query) async {
    _isLoading = true;
    notifyListeners();

    final result = await FriendService.searchUsers(query);

    if (result['success']) {
      // Filter out users who are already friends
      _searchResults = (result['users'] as List<UserModel>)
          .where((user) => !isFriend(user.id))
          .toList();
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check if user is friend
  bool isFriend(int userId) {
    return _friends.any((friend) => friend.id == userId);
  }
}