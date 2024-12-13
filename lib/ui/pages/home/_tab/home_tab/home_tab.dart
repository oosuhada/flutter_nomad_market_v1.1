import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/widgets/home_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/widgets/home_tab_popupbutton.dart';
import 'package:flutter_market_app/ui/widgets/home_tab_list_view.dart';

class HomeTab extends StatelessWidget {
  final List<String> categories = ['Category1', 'Category2', 'Category3'];
  //TODO:lib/ui/product_category_box.dart에서 카테고리 연결
  final String selectedCategory = '카테고리';

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          HomeTabAppBar(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                HomeTabPopupButton(
                  selectedValue: selectedCategory,
                  items: categories,
                  onChanged: (String? newValue) {
                    // Handle category change
                  },
                ),
                const SizedBox(width: 8),
                HomeTabPopupButton(
                  selectedValue: '거래방식',
                  items: ['거래방식', '직거래', '택배거래'],
                  onChanged: (String? newValue) {
                    // Handle trading method change
                  },
                ),
                const SizedBox(width: 8),
                HomeTabPopupButton(
                  selectedValue: '모든상품',
                  items: ['모든상품', '새상품', '중고상품'],
                  onChanged: (String? newValue) {
                    // Handle product type change
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    // Handle sort button press
                  },
                ),
              ],
            ),
          ),
          HomeTabListView(),
        ],
      ),
    );
  }
}
