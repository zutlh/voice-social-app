import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/ws_client.dart';
import 'package:frontend/app/theme.dart';
import 'widgets/seat_board.dart';
import 'widgets/chat_panel.dart';
import 'widgets/room_toolbar.dart';

class RoomPage extends ConsumerStatefulWidget {
  final int roomId;

  const RoomPage({super.key, required this.roomId});

  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage> {
  WsClient? _wsClient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initRoom());
  }

  Future<void> _initRoom() async {
    final roomNotifier = ref.read(roomProvider.notifier);

    // Join room via API
    try {
      await roomNotifier.joinRoom(widget.roomId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加入房间失败: $e')),
      );
      return;
    }

    // Get auth token for WebSocket
    final authState = ref.read(authProvider);
    final token = authState.accessToken ?? '';

    if (!mounted) return;

    // Create and connect WebSocket client
    final ws = WsClient(
      onMessage: _handleWsMessage,
      onDisconnected: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('与房间的连接已断开')),
        );
      },
    );
    ws.connect(token, widget.roomId);

    setState(() => _wsClient = ws);
  }

  void _handleWsMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    final data = msg['data'] as Map<String, dynamic>?;

    if (type == null) return;

    switch (type) {
      case 'CHAT_MSG':
        final content = data?['content'] as String?;
        if (content != null) {
          ref.read(roomProvider.notifier).addMessage(content);
        }
        break;
      case 'SEAT_UPDATE':
        ref.read(roomProvider.notifier).loadSeats(widget.roomId);
        break;
    }
  }

  @override
  void dispose() {
    _wsClient?.disconnect();
    // Leave room via API
    ref.read(roomProvider.notifier).leaveRoom(widget.roomId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    final wsClient = _wsClient;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          roomState.currentRoomId != null
              ? '房间 ${roomState.currentRoomId}'
              : '房间 ${widget.roomId}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          if (roomState.seats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${roomState.seats.where((s) => s.isOccupied).length}人在线',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: wsClient == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Seat board
                Expanded(
                  flex: 1,
                  child: SeatBoard(wsClient: wsClient),
                ),
                // Chat panel
                Expanded(
                  flex: 2,
                  child: ChatPanel(wsClient: wsClient),
                ),
                // Toolbar
                RoomToolbar(wsClient: wsClient),
              ],
            ),
    );
  }
}
