import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/app/theme.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    try {
      final api = ref.read(apiClientProvider);
      final resp = await api.get('/api/v1/auth/profile');
      if (!mounted) return;
      final user = User.fromJson(resp.data['data']);
      ref.read(authProvider.notifier).updateUser(user);
    } catch (_) {}
  }

  Future<void> _editNickname(String currentNickname) async {
    final controller = TextEditingController(text: currentNickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('修改昵称', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(hintText: '请输入新昵称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.put('/api/v1/auth/profile', data: {'nickname': result});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称已更新')),
      );
      _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('修改失败: $e')),
      );
    }
  }

  Future<void> _editGender(String currentGender) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('选择性别', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('男', style: TextStyle(color: Colors.white)),
              leading: Icon(
                currentGender == 'MALE' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppTheme.primary,
              ),
              onTap: () => Navigator.pop(ctx, 'MALE'),
            ),
            ListTile(
              title: const Text('女', style: TextStyle(color: Colors.white)),
              leading: Icon(
                currentGender == 'FEMALE' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppTheme.primary,
              ),
              onTap: () => Navigator.pop(ctx, 'FEMALE'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.put('/api/v1/auth/profile', data: {'gender': result});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('性别已更新')),
      );
      _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('修改失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => _editNickname(user?.nickname ?? ''),
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
                      onTap: () => _editGender(user?.gender ?? 'UNKNOWN'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
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
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
