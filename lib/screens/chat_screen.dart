import 'package:material_ui/material_ui.dart';

import '../services/chat.dart';
import '../theme.dart';

/// Simple text line between driver and passenger.
class ChatScreen extends StatefulWidget {
  final ChatThread thread;
  final String partnerName;
  final List<String> quickReplies;

  const ChatScreen({
    super.key,
    required this.thread,
    required this.partnerName,
    this.quickReplies = const [],
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = (text ?? _input.text).trim();
    if (message.isEmpty) return;
    widget.thread.send(message, mine: true);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partnerName)),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.thread,
              builder: (context, _) {
                final messages = widget.thread.messages;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet',
                        style: TextStyle(color: Colors.black54)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _Bubble(messages[i]),
                );
              },
            ),
          ),
          if (widget.quickReplies.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final reply in widget.quickReplies)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(reply),
                        onPressed: () => _send(reply),
                      ),
                    ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(hintText: 'Message'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send, color: AppColors.green),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble(this.message);

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mine ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text,
            style: TextStyle(color: mine ? Colors.white : Colors.black87)),
      ),
    );
  }
}
