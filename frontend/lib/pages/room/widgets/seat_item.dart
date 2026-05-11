import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/models/seat_info.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/ws_client.dart';

class SeatItem extends ConsumerWidget {
  final SeatInfo seat;
  final WsClient wsClient;

  const SeatItem({
    super.key,
    required this.seat,
    required this.wsClient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).userId;
    final isSelf = currentUserId != null && seat.userId == currentUserId;

    IconData icon;
    String label;

    if (seat.isFree) {
      icon = Icons.person_add_alt_1;
      label = '空闲';
    } else if (seat.isLocked) {
      icon = Icons.lock;
      label = '已锁定';
    } else {
      icon = Icons.person;
      label = seat.userName.isNotEmpty ? seat.userName : '有人';
    }

    final Color statusColor = seat.isFree
        ? AppTheme.seatFree
        : seat.isLocked
            ? AppTheme.seatLocked
            : AppTheme.seatOccupied;

    return GestureDetector(
      onTap: () {
        if (seat.isFree) {
          wsClient.applySeat(seat.index);
        } else if (seat.isOccupied && isSelf) {
          wsClient.releaseSeat();
        }
        // LOCKED: no action
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Seat index badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${seat.index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Icon
            Icon(icon, size: 24, color: statusColor),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    seat.isOccupied ? Colors.white : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (seat.isOccupied && seat.micOpen)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.mic, size: 12, color: AppTheme.accent),
              ),
            if (isSelf)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '我',
                  style: TextStyle(fontSize: 8, color: AppTheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
