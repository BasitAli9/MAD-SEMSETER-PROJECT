import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/colors.dart';
import '../../providers/friend_provider.dart';
import '../../widgets/friend_tile.dart';
import '../chat/chat_screen.dart';
import '../../models/friend_request_model.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({Key? key}) : super(key: key);

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadFriendRequests();
  }

  Future<void> _loadFriends() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.loadFriends();
  }

  Future<void> _loadFriendRequests() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.loadFriendRequests();
  }

  void _showFriendRequests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<FriendProvider>(
            builder: (context, friendProvider, child) {
              final requests = friendProvider.friendRequests;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider, borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Friend Requests',
                          style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold,),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric( horizontal: 8, vertical: 2,),
                          decoration: BoxDecoration(
                            color: AppColors.accent, borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Requests List
                  Expanded(
                    child: requests.isEmpty
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon( Icons.inbox_outlined, size: 64, color: AppColors.textLight,),
                          SizedBox(height: 16),
                          Text(
                            'No pending requests',
                            style: TextStyle( fontSize: 16, color: AppColors.textLight,),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      controller: scrollController,
                      itemCount: requests.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _buildRequestTile(request);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestTile(FriendRequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50, height: 50,
            decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                request.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w600,),
                ),
                Text(
                  request.email,
                  style: const TextStyle( fontSize: 13, color: AppColors.textLight, ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final friendProvider = Provider.of<FriendProvider>(
                    context,
                    listen: false,
                  );
                  final result = await friendProvider.acceptFriendRequest(
                    request.requestId,
                  );

                  if (!context.mounted) return;

                  if (result['success']) {
                    Fluttertoast.showToast(
                      msg: 'Friend request accepted',
                      backgroundColor: AppColors.success,
                    );
                    _loadFriends();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final friendProvider = Provider.of<FriendProvider>(
                    context,
                    listen: false,
                  );
                  await friendProvider.rejectFriendRequest(
                    request.requestId,
                  );
                },
                style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(horizontal: 12),),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(int friendId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $name from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final friendProvider = Provider.of<FriendProvider>(
                context,
                listen: false,
              );

              final result = await friendProvider.removeFriend(friendId);

              if (!mounted) return;

              if (result['success']) {
                Fluttertoast.showToast(
                  msg: 'Friend removed successfully', backgroundColor: AppColors.success,
                );
              } else {
                Fluttertoast.showToast(
                  msg: result['message'] ?? 'Failed to remove friend', backgroundColor: AppColors.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text( 'Remove',  style: TextStyle(fontSize: 12, color: Colors.white,), ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(int friendId, String friendName, bool isOnline) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          friendName: friendName,
          friendId: friendId,
          isOnline: isOnline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Friends'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<FriendProvider>(
            builder: (context, friendProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: _showFriendRequests,
                  ),
                  if (friendProvider.requestCount > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints( minWidth: 16, minHeight: 16,),
                        child: Text(
                          '${friendProvider.requestCount}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFriends,
          ),
        ],
      ),
      body: Consumer<FriendProvider>(
        builder: (context, friendProvider, child) {
          if (friendProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (friendProvider.friends.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadFriends,
            child: ListView.builder(
              itemCount: friendProvider.friends.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final friend = friendProvider.friends[index];
                return FriendTile(
                  name: friend.name,
                  email: friend.email,
                  isOnline: friend.isOnline,
                  onTap: () => _navigateToChat(
                    friend.id,
                    friend.name,
                    friend.isOnline,
                  ),
                  onMessage: () => _navigateToChat(
                    friend.id,
                    friend.name,
                    friend.isOnline,
                  ),
                  onRemove: () => _showRemoveDialog(friend.id, friend.name),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon( Icons.people_outline, size: 80, color: AppColors.textLight,),
          const SizedBox(height: 16),
          const Text(
            'No friends yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark,),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start adding friends to chat',
            style: TextStyle( fontSize: 14, color: AppColors.textLight,),
          ),
        ],
      ),
    );
  }
}