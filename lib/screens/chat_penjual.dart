import 'package:flutter/material.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';

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
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 68,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: BagiPorsiColors.border),
        ),
        title: Row(
          children: [
            FoodPhoto(food: widget.restaurant, size: 40, radius: 14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: BagiPorsiColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Flexible(
                        child: Text(
                          'Percakapan dengan toko',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<bool>(
            tooltip: 'Opsi percakapan',
            icon: const Icon(Icons.more_horiz),
            onSelected: (completed) {
              widget.store.setCompleted(
                widget.restaurant.merchantName,
                completed,
              );
              Navigator.pop(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: !widget.store.isCompleted(
                  widget.restaurant.merchantName,
                ),
                child: Text(
                  widget.store.isCompleted(widget.restaurant.merchantName)
                      ? 'Aktifkan kembali'
                      : 'Tandai selesai',
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            if (constraints.maxHeight > 380) _buildFoodSummary(),
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
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildChatBubble(messages[messages.length - 1 - index]),
                  );
                },
              ),
            ),
            if (constraints.maxHeight > 380)
              ListenableBuilder(
                listenable: widget.store,
                builder: (context, child) =>
                    widget.store
                        .messagesFor(widget.restaurant.merchantName)
                        .isEmpty
                    ? const SizedBox.shrink()
                    : _buildQuickReplies(),
              ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSummary() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BagiPorsiColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openFoodDetails(context, widget.restaurant),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FoodPhoto(food: widget.restaurant, size: 50, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.foodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: BagiPorsiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.restaurant.discountPrice} · Sisa ${widget.restaurant.portionsLeft} porsi',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BagiPorsiColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BagiPorsiColors.mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BagiPorsiColors.green,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: BagiPorsiColors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildQuickReplies() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      children: [
        for (final text in [
          'Apakah masih tersedia?',
          'Saya sedang menuju lokasi',
          'Sudah sampai',
        ])
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: BagiPorsiColors.ink,
                ),
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: BagiPorsiColors.border),
              shape: const StadiumBorder(),
              onPressed: () => _useSuggestion(text),
            ),
          ),
      ],
    ),
  );

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
                  label: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: BagiPorsiColors.border),
                  shape: const StadiumBorder(),
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 288),
        decoration: BoxDecoration(
          color: BagiPorsiColors.mint,
          border: Border.all(color: const Color(0xFFC8EADF)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: BagiPorsiColors.ink,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 11,
                  color: BagiPorsiColors.muted,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${TimeOfDay.fromDateTime(message.createdAt).format(context)} · Belum terkirim',
                    style: const TextStyle(
                      color: BagiPorsiColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BagiPorsiColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: BagiPorsiColors.border),
                ),
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
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF858D89),
                    ),
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
