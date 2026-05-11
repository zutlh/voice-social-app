import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/services/ws_client.dart';
import 'seat_item.dart';

class SeatBoard extends ConsumerWidget {
  final WsClient wsClient;

  const SeatBoard({super.key, required this.wsClient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = ref.watch(roomProvider).seats;

    if (seats.isEmpty) {
      return const Center(
        child: Text(
          '暂无座位',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: seats.length,
        itemBuilder: (_, index) {
          final seat = seats[index];
          return SeatItem(
            seat: seat,
            wsClient: wsClient,
          );
        },
      ),
    );
  }
}
