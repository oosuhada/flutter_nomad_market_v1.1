import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/widgets/product_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer(builder: (context, ref, child) {
        final homeTabState = ref.watch(homeTabViewModel);
        final products = homeTabState.products;
        return ListView.separated(
          itemCount: products.length,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          itemBuilder: (context, index) {
            return ProductListItem(products[index]);
          },
          separatorBuilder: (context, index) {
            return Divider(height: 20);
          },
        );
      }),
    );
  }
}
