import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_list_view.dart';

class WishListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관심목록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: HomeTabListView(),
    );
  }
}
