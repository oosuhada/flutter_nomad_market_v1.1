import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/chat_tab/chat_tab.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/my_tab.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeIndexedStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentIndex = ref.watch(homeViewModel);
        return IndexedStack(
          index: currentIndex,
          children: [
            HomeTab(),
            ChatTab(),
            MyTab(),
          ],
        );
      },
    );
  }
}
