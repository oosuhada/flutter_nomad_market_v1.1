import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/widgets/home_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/widgets/home_tab_list_view.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          HomeTabAppBar(),
          HomeTabListView(),
        ],
      ),
    );
  }
}
