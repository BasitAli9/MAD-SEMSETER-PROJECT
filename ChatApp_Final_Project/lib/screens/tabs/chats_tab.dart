import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_tile.dart';
import '../chat/chat_screen.dart';

class ChatsTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const ChatsTab({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('hh:mm a').format(date);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }
    catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card, // subtle bg for search
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.icon),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric( horizontal: 16, vertical: 12, ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Conversations List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var conversations = chatProvider.conversations;
                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  conversations = conversations.where((conv) {
                    return conv.friendName
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                if (conversations.isEmpty) { return _buildEmptyState(); }

                return RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return ChatTile(
                        name: conv.friendName,
                        lastMessage: conv.lastMessage ?? 'No messages yet',
                        timestamp: _formatTimestamp(conv.lastMessageTime),
                        unreadCount: conv.unreadCount,
                        isOnline: conv.isOnline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                friendName: conv.friendName,
                                friendId: conv.friendId,
                                isOnline: conv.isOnline,
                                conversationId: conv.conversationId,
                              ),
                            ),
                          );
                        },
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,  height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary, borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon( Icons.chat_bubble_outline, size: 60, color: AppColors.accent,),
            ),
            const SizedBox(height: 24),
            const Text(
              'No conversations yet',
              style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark,),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect with friends and start\nmeaningful conversations',
              textAlign: TextAlign.center,
              style: TextStyle( fontSize: 14, color: AppColors.textLight, ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Find Friends tab (index 2)
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(2);
                    }
                    DefaultTabController.of(context)?.animateTo(2);
                  },
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text('Find People'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric( horizontal: 20,  vertical: 12, ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Friends tab (index 1)
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1);
                    }
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                  icon: const Icon(Icons.people, size: 20),
                  label: const Text('View Friends'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric( horizontal: 20, vertical: 12,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}