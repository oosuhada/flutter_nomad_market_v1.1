import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailBottomSheet extends ConsumerStatefulWidget {
  ChatDetailBottomSheet(this.bottomPadding);

  final double bottomPadding;

  @override
  ConsumerState<ChatDetailBottomSheet> createState() =>
      _ChatDetailBottomSheetState();
}

class _ChatDetailBottomSheetState extends ConsumerState<ChatDetailBottomSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onSend() {
    final vm = ref.read(chatGlobalViewModel.notifier);
    final text = controller.text;
    if (text.trim().isNotEmpty) {
      vm.send(text);
      controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70 + widget.bottomPadding,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                //
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (v) => onSend(),
                  ),
                ),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: widget.bottomPadding),
        ],
      ),
    );
  }
}
