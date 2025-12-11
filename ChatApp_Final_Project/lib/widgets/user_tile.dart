import 'package:flutter/material.dart';
import '../config/colors.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onAdd;

  const UserTile({
    Key? key,
    required this.name,
    required this.email,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow( color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2),),
        ],
      ),
      child: Row(
        children: [
          // Profile
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration( color: AppColors.accent, shape: BoxShape.circle,),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
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
                  style: const TextStyle( fontSize: 13, color: AppColors.textLight,),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Add Friend Button
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric( horizontal: 16, vertical: 8,),
            ),
          ),
        ],
      ),
    );
  }
}