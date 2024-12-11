import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/widgets/chat_detail_bottom_sheet.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/widgets/chat_detail_list_view.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/widgets/chat_detail_product_area.dart';

class ChatDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('오상구'),
          centerTitle: true,
        ),
        bottomSheet: ChatDetailBottomSheet(
          MediaQuery.of(context).padding.bottom,
        ),
        body: Column(
          children: [
            ChatDetailProductArea(),
            ChatDetailListView(),
          ],
        ),
      ),
    );
  }
}
