import 'package:flutter/material.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';

class ChatPenjual extends StatefulWidget {
  const ChatPenjual({super.key, required this.restaurant, required this.store});

  final FoodListing restaurant;
  final ChatStore store;

  @override
  State<ChatPenjual> createState() => _ChatPenjualState();
}

class _ChatPenjualState extends State<ChatPenjual> {
  late final _messageController = TextEditingController(
    text: widget.store.draftFor(widget.restaurant.merchantName),
  );
  final _messageFocus = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    widget.store.queueMessage(widget.restaurant.merchantName, text);
    _messageController.clear();
  }

  void _useSuggestion(String text) {
    _messageController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.store.saveDraft(widget.restaurant.merchantName, text);
    _messageFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BagiPorsiColors.canvas,
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: BagiPorsiColors.mint,
              child: Icon(Icons.storefront, color: BagiPorsiColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.merchantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Percakapan dengan toko',
                    style: TextStyle(fontSize: 12, color: Color(0xFFD7F2E9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, child) {
                final messages = widget.store.messagesFor(
                  widget.restaurant.merchantName,
                );
                if (messages.isEmpty) return _buildEmptyConversation();
                return ListView.builder(
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildChatBubble(messages[messages.length - 1 - index]),
                );
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyConversation() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: BagiPorsiColors.mint,
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 32,
              color: BagiPorsiColors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mulai percakapan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: BagiPorsiColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tanyakan tentang ${widget.restaurant.foodName} '
            'atau atur waktu pengambilan dengan toko.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: BagiPorsiColors.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final text in [
                'Apakah masih tersedia?',
                'Bisa diambil jam berapa?',
              ])
                ActionChip(
                  label: Text(text),
                  onPressed: () => _useSuggestion(text),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        constraints: const BoxConstraints(maxWidth: 282),
        decoration: BoxDecoration(
          color: BagiPorsiColors.green,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${TimeOfDay.fromDateTime(message.createdAt).format(context)} · Belum terkirim',
              style: const TextStyle(color: Color(0xFFD7F2E9), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BagiPorsiColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocus,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                onChanged: (text) => widget.store.saveDraft(
                  widget.restaurant.merchantName,
                  text,
                ),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: BagiPorsiColors.canvas,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, child) => IconButton.filled(
                tooltip: 'Kirim pesan',
                icon: const Icon(Icons.send_rounded, size: 20),
                onPressed: value.text.trim().isEmpty ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: BagiPorsiColors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
