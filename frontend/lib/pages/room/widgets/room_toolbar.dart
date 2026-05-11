import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/ws_client.dart';
import 'gift_sheet.dart';

class RoomToolbar extends ConsumerWidget {
  final WsClient wsClient;

  const RoomToolbar({super.key, required this.wsClient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(roomProvider);
    final currentUserId = ref.watch(authProvider).userId;
    final seats = roomState.seats;

    // Check if current user is on any seat
    final isOnSeat = currentUserId != null &&
        seats.any((s) => s.isOccupied && s.userId == currentUserId);

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.background, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Apply/Release seat
          _ToolbarButton(
            icon: isOnSeat ? Icons.voice_chat : Icons.mic,
            label: isOnSeat ? '下麦' : '上麦',
            color: isOnSeat ? AppTheme.seatOccupied : AppTheme.seatFree,
            onTap: () {
              if (isOnSeat) {
                wsClient.releaseSeat();
              } else {
                // Apply to first free seat
                final freeSeat = seats.indexWhere((s) => s.isFree);
                if (freeSeat >= 0) {
                  wsClient.applySeat(freeSeat);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('没有空闲座位')),
                  );
                }
              }
            },
          ),
          // Send gift
          _ToolbarButton(
            icon: Icons.card_giftcard,
            label: '送礼',
            color: AppTheme.gold,
            onTap: () {
              final targetUserId = seats
                  .where((s) => s.isOccupied)
                  .map((s) => s.userId)
                  .firstWhere((id) => id != null, orElse: () => null);
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => GiftSheet(
                  roomId: roomState.currentRoomId,
                  toUid: targetUserId ?? 0,
                ),
              );
            },
          ),
          // Leave
          _ToolbarButton(
            icon: Icons.exit_to_app,
            label: '离开',
            color: AppTheme.textSecondary,
            onTap: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
