import 'package:flutter/foundation.dart';

class ChatMessage {
  final String from;
  final String text;
  final bool mine;
  const ChatMessage(this.from, this.text, {required this.mine});
}

/// In-memory text conversation between driver and passenger for the demo.
/// A real version would send messages through a server.
class ChatThread extends ChangeNotifier {
  final List<ChatMessage> messages = [];

  void send(String text, {required bool mine, String from = 'You'}) {
    messages.add(ChatMessage(from, text, mine: mine));
    notifyListeners();
  }
}
