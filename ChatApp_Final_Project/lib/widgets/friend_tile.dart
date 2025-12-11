import 'package:flutter/material.dart';
import '../config/colors.dart';

class FriendTile extends StatelessWidget {
  final String name;
  final String email;
  final bool isOnline;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onRemove;

  const FriendTile({
    Key? key,
    required this.name,
    required this.email,
    this.isOnline = false,
    required this.onTap,
    required this.onMessage,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile with Online Status
            Stack(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.online : AppColors.offline,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2,),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Friend Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 13, color: AppColors.textLight,),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12, color: isOnline ? AppColors.online : AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppColors.accent, iconSize: 22, onPressed: onMessage, tooltip: 'Message',
                ),
                IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  color: AppColors.error, iconSize: 22, onPressed: onRemove, tooltip: 'Remove Friend',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}