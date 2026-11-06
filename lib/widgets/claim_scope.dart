import 'package:flutter/widgets.dart';

import '../data/chat_store.dart';
import '../data/claim_store.dart';

class ClaimScope extends InheritedNotifier<ClaimStore> {
  const ClaimScope({
    super.key,
    required ClaimStore store,
    required this.chatStore,
    this.onOpenClaims,
    required super.child,
  }) : super(notifier: store);
  final ChatStore chatStore;
  final VoidCallback? onOpenClaims;
  ClaimStore get store => notifier!;
  static ClaimScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ClaimScope>();
}
