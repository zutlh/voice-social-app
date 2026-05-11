import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../models/seat_info.dart';
import '../services/api_client.dart';

class RoomState {
  final List<Room> rooms;
  final List<SeatInfo> seats;
  final List<String> messages;
  final int? currentRoomId;
  final String? channelName;
  final String? agoraToken;
  final int? agoraUid;
  final bool isLoading;

  const RoomState({this.rooms = const [], this.seats = const [], this.messages = const [], this.currentRoomId, this.channelName, this.agoraToken, this.agoraUid, this.isLoading = false});
}

class RoomNotifier extends Notifier<RoomState> {
  @override
  RoomState build() => const RoomState();

  Future<void> loadRooms({String? category}) async {
    state = RoomState(rooms: state.rooms, isLoading: true);
    final api = ref.read(apiClientProvider);
    final resp = await api.get('/api/v1/rooms', params: {'category': category ?? ''});
    final list = (resp.data['data']['records'] as List).map((e) => Room.fromJson(e)).toList();
    state = RoomState(rooms: list);
  }

  Future<void> createRoom(String name, String category, int seatCount) async {
    final api = ref.read(apiClientProvider);
    await api.post('/api/v1/rooms', data: {'name': name, 'category': category, 'seatCount': seatCount});
    await loadRooms();
  }

  Future<void> joinRoom(int roomId) async {
    final api = ref.read(apiClientProvider);
    final resp = await api.post('/api/v1/rooms/$roomId/join');
    final data = resp.data['data'];
    state = RoomState(
      rooms: state.rooms,
      currentRoomId: roomId,
      channelName: data['channelName'],
      agoraToken: data['agoraToken'],
      agoraUid: data['agoraUid'],
    );
    await loadSeats(roomId);
  }

  Future<void> leaveRoom(int roomId) async {
    final api = ref.read(apiClientProvider);
    await api.post('/api/v1/rooms/$roomId/leave');
    state = const RoomState();
  }

  Future<void> loadSeats(int roomId) async {
    final api = ref.read(apiClientProvider);
    final resp = await api.get('/api/v1/rooms/$roomId/seats');
    final seats = (resp.data['data'] as List).map((e) => SeatInfo.fromJson(e)).toList();
    state = RoomState(rooms: state.rooms, seats: seats, messages: state.messages, currentRoomId: state.currentRoomId, channelName: state.channelName, agoraToken: state.agoraToken, agoraUid: state.agoraUid);
  }

  void addMessage(String msg) {
    state = RoomState(rooms: state.rooms, seats: state.seats, messages: [...state.messages, msg], currentRoomId: state.currentRoomId, channelName: state.channelName, agoraToken: state.agoraToken, agoraUid: state.agoraUid);
  }
}

final roomProvider = NotifierProvider<RoomNotifier, RoomState>(RoomNotifier.new);
