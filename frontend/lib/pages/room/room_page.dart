import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  final int roomId;

  const RoomPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room $roomId')),
      body: Center(
        child: Text('Room Page - ID: $roomId'),
      ),
    );
  }
}
