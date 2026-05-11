import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/app/theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '个人资料',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.card,
              child: user?.avatar.isNotEmpty == true
                  ? ClipOval(
                      child: Image.network(
                        user!.avatar,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.textSecondary,
                    ),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: '昵称',
                      value: user?.nickname.isNotEmpty == true
                          ? user!.nickname
                          : '未设置',
                    ),
                    const Divider(color: AppTheme.background),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: '手机号',
                      value: user?.phone.isNotEmpty == true
                          ? user!.phone
                          : '未设置',
                    ),
                    const Divider(color: AppTheme.background),
                    _InfoRow(
                      icon: Icons.wc,
                      label: '性别',
                      value: _genderLabel(user?.gender),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.seatOccupied,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(String? gender) {
    switch (gender) {
      case 'MALE':
        return '男';
      case 'FEMALE':
        return '女';
      default:
        return '未设置';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
