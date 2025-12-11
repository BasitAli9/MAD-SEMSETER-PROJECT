import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/socket_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/friend_provider.dart';
import 'tabs/chats_tab.dart';
import 'tabs/friends_tab.dart';
import 'tabs/find_friends_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _initializeSocket();
    _loadFriendRequestCount();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  Future<void> _initializeSocket() async {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    await socketProvider.initSocket();

    if (authProvider.user != null) {
      chatProvider.initializeChat(authProvider.user!.id);
    }
  }

  Future<void> _loadFriendRequestCount() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.loadRequestCount();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ChatsTab(onNavigateToTab: (index) => _tabController.animateTo(index)),
      const FriendsTab(),
      const FindFriendsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Talk'),
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'CHATS'),
            Tab(
              child: Consumer<FriendProvider>(
                builder: (context, friendProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('FRIENDS'),
                      if (friendProvider.requestCount > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${friendProvider.requestCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const Tab(text: 'FIND'),
            const Tab(text: 'PROFILE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs,
      ),
      floatingActionButton: _currentIndex == 0 // Show FAB on CHATS tab
          ? FloatingActionButton(
              onPressed: () {
                _tabController.animateTo(2); // Navigate to FIND tab to start a new chat
              },
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.chat, color: Colors.white),
            )
          : _currentIndex == 1 // Show FAB on FRIENDS tab
          ? FloatingActionButton(
              onPressed: () {
                 _tabController.animateTo(2); // Navigate to FIND tab to add friends
              },
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }
}
