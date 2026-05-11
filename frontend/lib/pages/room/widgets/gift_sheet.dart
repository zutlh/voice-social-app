import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/models/gift.dart';
import 'package:frontend/services/api_client.dart';

String giftEmoji(String name) {
  switch (name) {
    case '小星星': return '⭐';
    case '玫瑰花': return '🌹';
    case '巧克力': return '🍫';
    case '烟花': return '🎆';
    case '城堡': return '🏰';
    case '跑车': return '🏎';
    case '钻戒': return '💍';
    default: return '🎁';
  }
}

class GiftSheet extends ConsumerStatefulWidget {
  final int? roomId;

  const GiftSheet({super.key, this.roomId});

  @override
  ConsumerState<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends ConsumerState<GiftSheet> {
  List<Gift> _gifts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    try {
      final api = ref.read(apiClientProvider);
      final resp = await api.get('/api/v1/gifts');
      final list = (resp.data['data'] as List)
          .map((e) => Gift.fromJson(e))
          .toList();
      if (!mounted) return;
      setState(() {
        _gifts = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _sendGift(Gift gift) async {
    final quantityController = TextEditingController(text: '1');

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            '赠送 ${gift.name}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${giftEmoji(gift.name)}  ${gift.price} 金币/个',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '数量',
                  hintText: '1',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final qty =
                    int.tryParse(quantityController.text.trim()) ?? 1;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('数量必须大于0')),
                  );
                  return;
                }
                Navigator.of(ctx).pop(qty);
              },
              child: const Text('赠送'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.post('/api/v1/gifts/send', data: {
        'giftId': gift.id,
        'quantity': result,
        if (widget.roomId != null) 'roomId': widget.roomId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('赠送成功!')),
      );
      Navigator.of(context).pop(); // Close the bottom sheet
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('赠送失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '赠送礼物',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.background),
          // Gift grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _gifts.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无礼物',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _gifts.length,
                        itemBuilder: (_, index) {
                          final gift = _gifts[index];
                          return _GiftTile(
                            gift: gift,
                            onTap: () => _sendGift(gift),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  final Gift gift;
  final VoidCallback onTap;

  const _GiftTile({required this.gift, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              giftEmoji(gift.name),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${gift.price}金币',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
