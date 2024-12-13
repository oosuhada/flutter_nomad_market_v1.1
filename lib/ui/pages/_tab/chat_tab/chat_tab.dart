import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/chat_tab/widgets/chat_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/chat_tab/widgets/chat_tab_list_view.dart';

class ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          ChatTabAppBar(),
          ChatTabListView(),
        ],
      ),
    );
  }
}
