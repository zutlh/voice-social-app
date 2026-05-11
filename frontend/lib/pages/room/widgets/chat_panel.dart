import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/room_provider.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/services/ws_client.dart';

class ChatPanel extends ConsumerStatefulWidget {
  final WsClient wsClient;

  const ChatPanel({super.key, required this.wsClient});

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.wsClient.sendChat(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(roomProvider).messages;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messages.length != _lastMessageCount) {
        _lastMessageCount = messages.length;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.background,
                  width: 1,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(
                  '聊天',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      '暂无消息',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: _MessageBubble(message: messages[index]),
                      );
                    },
                  ),
          ),
          // Input row
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.background,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppTheme.primary),
                  iconSize: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Messages are expected in format: "userName: text"
    final parts = message.split(': ');
    final sender = parts.length > 1 ? parts[0] : '';
    final content = parts.length > 1 ? parts.sublist(1).join(': ') : message;

    return RichText(
      text: TextSpan(
        children: [
          if (sender.isNotEmpty)
            TextSpan(
              text: '$sender: ',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          TextSpan(
            text: content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
