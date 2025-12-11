import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final result = await authProvider.deleteAccount();
              if (!mounted) return;
              if (result['success']) {
                Fluttertoast.showToast(msg: 'Account deleted successfully', backgroundColor: AppColors.success);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              } else {
                Fluttertoast.showToast(
                  msg: result['message'] ?? 'Failed to delete account',
                  backgroundColor: AppColors.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                Fluttertoast.showToast(msg: 'Name cannot be empty', backgroundColor: AppColors.error);
                return;
              }
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final result = await authProvider.updateName(controller.text.trim());
              if (!mounted) return;
              if (result['success']) {
                Fluttertoast.showToast(msg: 'Name updated successfully', backgroundColor: AppColors.success);
              } else {
                Fluttertoast.showToast(
                  msg: result['message'] ?? 'Failed to update name',
                  backgroundColor: AppColors.error,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password', border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                Fluttertoast.showToast(msg: 'All fields are required', backgroundColor: AppColors.error);
                return;
              }
              if (newPasswordController.text != confirmPasswordController.text) {
                Fluttertoast.showToast(msg: 'Passwords do not match', backgroundColor: AppColors.error);
                return;
              }
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final result = await authProvider.changePassword(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
              );
              if (!mounted) return;
              if (result['success'])
              {
                Fluttertoast.showToast(msg: 'Password changed successfully', backgroundColor: AppColors.success);
              }
              else {
                Fluttertoast.showToast(msg: result['message'] ?? 'Failed to change password', backgroundColor: AppColors.error);
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: AppColors.scaffold,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: const Color(0xFFCDE9DC),
            title: const Text(
              'Profile',
              style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4F7F76)),
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9ECCE), shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle( fontSize: 14, color: AppColors.textLight,),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCard(
                    title: 'Account Settings',
                    children: [
                      _buildTile(
                        icon: Icons.person_outline,
                        title: 'Edit Name',
                        onTap: () => _showEditNameDialog(user?.name ?? ''),
                      ),
                      _buildTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: _showChangePasswordDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Actions Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCard(
                    title: 'Actions',
                    children: [
                      _buildTile(
                        icon: Icons.logout,
                        title: 'Logout', iconColor: AppColors.error, textColor: AppColors.error,
                        onTap: _showLogoutDialog,
                      ),
                      _buildTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Account', iconColor: AppColors.error, textColor: AppColors.error,
                        onTap: _showDeleteAccountDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 16, color: textColor ?? AppColors.textDark)),
            ),
            Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}