import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentIndex = ref.watch(homeViewModel);
        final viewModel = ref.read(homeViewModel.notifier);
        return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: viewModel.onIndexChanged,
            iconSize: 28,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.house_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈',
                tooltip: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_2),
                activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
                label: '채팅',
                tooltip: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                activeIcon: Icon(CupertinoIcons.person_fill),
                label: '나의 마켓',
                tooltip: '나의 마켓',
              ),
            ]);
      },
    );
  }
}
