import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/connection_indicator.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String friendName;
  final int friendId;
  final bool isOnline;
  final int? conversationId;

  const ChatScreen({
    Key? key,
    required this.friendName,
    required this.friendId,
    required this.isOnline,
    this.conversationId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _conversationId;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (widget.conversationId != null)
    {
      _conversationId = widget.conversationId;
      await _loadMessages();
    } else
    {
      await _createConversation();
    }
  }

  Future<void> _createConversation() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final convId = await chatProvider.getOrCreateConversation(widget.friendId);

    if (convId != null) {
      setState(() {
        _conversationId = convId;
      });
      await _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(_conversationId!);
    _scrollToBottom();
    _markAsRead();
  }

  void _markAsRead() {
    if (_conversationId == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    //final authProvider = Provider.of<AuthProvider>(context, listen: false);

    chatProvider.markAsRead(_conversationId!, widget.friendId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _conversationId == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.sendMessage(
      conversationId: _conversationId!,
      receiverId: widget.friendId,
      message: _messageController.text.trim(),
    );

    _messageController.clear();
    _stopTyping();
    _scrollToBottom();
  }

  void _onTextChanged(String text) {
    if (_conversationId == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatProvider.sendTyping(widget.friendId, _conversationId!);
    }

    // Reset timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (_conversationId == null || !_isTyping) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _isTyping = false;
    chatProvider.stopTyping(widget.friendId, _conversationId!);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.friendName),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final isTyping = chatProvider.isUserTyping(widget.friendId);

                if (isTyping) {
                  return const Text(
                    'typing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.typing,
                    ),
                  );
                }

                return Text(
                  widget.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12, color: widget.isOnline ? AppColors.online : AppColors.textLight,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _conversationId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Connection Indicator
          const ConnectionIndicator(),
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessages(_conversationId!);

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message.senderId == currentUserId;

                    return _buildMessageBubble(
                      message.message,
                      isSent,
                      _formatTime(message.createdAt),
                      message.status == 'read', message.status == 'delivered',
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border( top: BorderSide(color: AppColors.divider), ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppColors.scaffold,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: _onTextChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      String message,
      bool isSent,
      String timestamp,
      bool isRead,
      bool isDelivered,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSent ? AppColors.sentMessage : AppColors.receivedMessage,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSent ? 16 : 4),
                bottomRight: Radius.circular(isSent ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: const TextStyle( fontSize: 15, color: AppColors.textDark,),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 11, color: AppColors.textLight.withOpacity(0.7),
                      ),
                    ),
                    if (isSent) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead
                            ? Icons.done_all
                            : isDelivered
                            ? Icons.done_all
                            : Icons.done,
                        size: 14,
                        color: isRead ? AppColors.accent : AppColors.textLight,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}