import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/colors.dart';
import '../../providers/friend_provider.dart';
import '../../widgets/user_tile.dart';

class FindFriendsTab extends StatefulWidget {
  const FindFriendsTab({Key? key}) : super(key: key);

  @override
  State<FindFriendsTab> createState() => _FindFriendsTabState();
}

class _FindFriendsTabState extends State<FindFriendsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllUsers(); // Load all users by default
  }

  Future<void> _loadAllUsers() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.searchUsers('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    friendProvider.searchUsers(query);
  }

  Future<void> _handleAddFriend(int userId, String name) async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    final result = await friendProvider.sendFriendRequest(userId);
    if (!mounted) return;

    if (result['success']) {
      Fluttertoast.showToast(
        msg: 'Friend request sent to $name',
        backgroundColor: AppColors.success,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to send request',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Find Friends'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.icon),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.icon),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _loadAllUsers(); // Reload all users
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.scaffold,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.length >= 2)
                {
                  _handleSearch(value);
                }
                else if (value.isEmpty) {
                  _loadAllUsers(); // Show all when cleared
                }
              },
            ),
          ),

          // Users List
          Expanded(
            child: Consumer<FriendProvider>(
              builder: (context, friendProvider, child) {
                if (friendProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (friendProvider.searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadAllUsers,
                  child: ListView.builder(
                    itemCount: friendProvider.searchResults.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final user = friendProvider.searchResults[index];
                      return UserTile(
                        name: user.name, email: user.email,
                        onAdd: () => _handleAddFriend(user.id, user.name),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon( Icons.search_off, size: 80, color: AppColors.textLight,),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'All users are already your friends'
                : 'Try searching with different keywords',
            style: const TextStyle(
              fontSize: 14, color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}