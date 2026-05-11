import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final void Function(Map<String, dynamic>) onMessage;
  final void Function()? onDisconnected;
  Timer? _heartbeat;

  WsClient({required this.onMessage, this.onDisconnected});

  void connect(String token, int roomId) {
    final uri = Uri.parse('ws://10.0.2.2:8080/ws/room?token=$token&roomId=$roomId');
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      (data) {
        final msg = jsonDecode(data as String) as Map<String, dynamic>;
        onMessage(msg);
      },
      onDone: () {
        _heartbeat?.cancel();
        onDisconnected?.call();
      },
      onError: (_) {
        _heartbeat?.cancel();
        onDisconnected?.call();
      },
    );
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      send({'type': 'HEARTBEAT', 'data': {}});
    });
  }

  void send(Map<String, dynamic> msg) {
    _channel?.sink.add(jsonEncode(msg));
  }

  void sendChat(String content) {
    send({'type': 'CHAT_SEND', 'data': {'content': content}});
  }

  void applySeat(int index) {
    send({'type': 'SEAT_APPLY', 'data': {'seatIndex': index}});
  }

  void releaseSeat() {
    send({'type': 'SEAT_RELEASE', 'data': {}});
  }

  void toggleMic(bool muted) {
    send({'type': 'SEAT_MUTE', 'data': {'muted': muted}});
  }

  void disconnect() {
    _heartbeat?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
  }
}
