import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/widgets/home_tab_list_view.dart';

class PurchaseHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구매내역'),
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