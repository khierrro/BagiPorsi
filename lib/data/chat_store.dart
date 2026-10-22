import 'package:flutter/foundation.dart';

class ChatMessage {
  ChatMessage(this.text) : createdAt = DateTime.now();

  final String text;
  final DateTime createdAt;
}

// In-memory conversations until a messaging service is connected.
// The store is owned by MainNavigation, so switching tabs preserves each draft.
class ChatStore extends ChangeNotifier {
  final _messages = <String, List<ChatMessage>>{};
  final _drafts = <String, String>{};

  List<ChatMessage> messagesFor(String merchantName) =>
      List.unmodifiable(_messages[merchantName] ?? const <ChatMessage>[]);

  String draftFor(String merchantName) => _drafts[merchantName] ?? '';

  void saveDraft(String merchantName, String text) {
    if (draftFor(merchantName) == text) return;
    if (text.isEmpty) {
      _drafts.remove(merchantName);
    } else {
      _drafts[merchantName] = text;
    }
    notifyListeners();
  }

  void queueMessage(String merchantName, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _messages.putIfAbsent(merchantName, () => []).add(ChatMessage(trimmed));
    _drafts.remove(merchantName);
    notifyListeners();
  }
}
