import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/models/room.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedCategory = '全部';

  static const _categories = ['全部', '游戏', '音乐', '聊天', '其他'];

  String? _categoryParam(String label) {
    if (label == '全部') return null;
    if (label == '游戏') return 'GAME';
    if (label == '音乐') return 'MUSIC';
    if (label == '聊天') return 'CHAT';
    if (label == '其他') return 'OTHER';
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomProvider.notifier).loadRooms();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(roomProvider.notifier).loadRooms(
      category: _categoryParam(_selectedCategory),
    );
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    ref.read(roomProvider.notifier).loadRooms(
      category: _categoryParam(category),
    );
  }

  Future<void> _showCreateRoomDialog() async {
    final nameController = TextEditingController();
    String selectedCategory = 'CHAT';
    int seatCount = 6;

    await showDialog(
      context: context,
      builder: (ctx) {
        String localCategory = selectedCategory;
        int localSeatCount = seatCount;

        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('创建房间', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (ctx, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '房间名称',
                      hintText: '输入房间名称',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: localCategory,
                    dropdownColor: AppTheme.surface,
                    decoration: const InputDecoration(labelText: '分类'),
                    items: const [
                      DropdownMenuItem(value: 'GAME', child: Text('游戏')),
                      DropdownMenuItem(value: 'MUSIC', child: Text('音乐')),
                      DropdownMenuItem(value: 'CHAT', child: Text('聊天')),
                      DropdownMenuItem(value: 'OTHER', child: Text('其他')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => localCategory = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('座位数: ', style: TextStyle(color: Colors.white)),
                      DropdownButton<int>(
                        value: localSeatCount,
                        dropdownColor: AppTheme.surface,
                        items: [2, 4, 6, 8].map((n) {
                          return DropdownMenuItem(value: n, child: Text('$n'));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => localSeatCount = v);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入房间名称')),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                await ref.read(roomProvider.notifier).createRoom(
                  name,
                  localCategory,
                  localSeatCount,
                );
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    final rooms = roomState.rooms;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '语音大厅',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined,
                color: AppTheme.gold),
            onPressed: () => context.push('/wallet'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (_, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.card,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    onSelected: (_) => _onCategoryChanged(cat),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: roomState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : rooms.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无房间',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppTheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: rooms.length,
                          itemBuilder: (_, index) {
                            final room = rooms[index];
                            return _RoomCard(
                              room: room,
                              onTap: () => context.push('/room/${room.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headphones,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          room.ownerName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.people_outline,
                      size: 18, color: AppTheme.textSecondary),
                  const SizedBox(height: 2),
                  Text(
                    '${room.onlineCount}/${room.maxUsers}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
