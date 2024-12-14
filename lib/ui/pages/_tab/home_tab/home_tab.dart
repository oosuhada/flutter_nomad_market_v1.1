import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_popupbutton.dart';
import 'package:flutter_market_app/ui/widgets/home_tab_list_view.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_view_model.dart';

class HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productWriteViewModel(null));
    final vm = ref.read(productWriteViewModel(null).notifier);

    return SizedBox.expand(
      child: Column(
        children: [
          HomeTabAppBar(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                HomeTabPopupButton(
                  selectedValue: state.selectedCategory?.category ?? '카테고리',
                  onChanged: (String newValue) {
                    vm.onCategorySelected(newValue);
                  },
                ),
                const SizedBox(width: 8),
                HomeTabPopupButton(
                  selectedValue: '거래방식',
                  //items: ['거래방식', '직거래', '택배거래'],
                  onChanged: (String? newValue) {
                    // Handle trading method change
                  },
                ),
                const SizedBox(width: 8),
                HomeTabPopupButton(
                  selectedValue: '모든상품',
                  //items: ['모든상품', '새상품', '중고상품'],
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
