import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/chat_global_view_model.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_detail/product_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProductDetailBottomSheet extends StatelessWidget {
  ProductDetailBottomSheet(this.bottomPadding, this.productId);

  final double bottomPadding;
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(productDetailViewModel(productId));
      final vm = ref.read(productDetailViewModel(productId).notifier);
      if (state == null) {
        return SizedBox();
      }
      return Container(
        height: 50 + bottomPadding,
        color: Colors.white,
        child: Column(
          children: [
            Divider(height: 0),
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await vm.like();
                      if (result) {
                        ref.read(homeTabViewModel.notifier).fetchProducts();
                      }
                      // 1. HomeTabViewModel 상태객체 업데이트
                      // 2. HomeTabViewModel의 fetchProducts 호출
                      // 3. HomeTab => pull to refresh => 지금 X
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.transparent,
                      child: Icon(state.myLike
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart),
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###원').format(state.price),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        // TODO 구현
                        final chatVm = ref.read(chatGlobalViewModel.notifier);

                        var roomId = chatVm.findChatRoomByProductId(productId);

                        if (roomId == null) {
                          final result = await chatVm.createChat(productId);
                          if (result != null) {
                            roomId = result;
                          }
                        }

                        if (roomId == null) {
                          return;
                        }

                        chatVm.fetchChatDetail(roomId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatDetailPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        '채팅하기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      );
    });
  }
}
