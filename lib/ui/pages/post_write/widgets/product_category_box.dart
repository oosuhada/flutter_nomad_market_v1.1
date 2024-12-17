import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCategoryBox extends StatelessWidget {
  ProductCategoryBox(this.product);

  final Post? product;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(postWriteViewModel(product));
      final vm = ref.read(postWriteViewModel(product).notifier);

      return Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: vm.onCategorySelected,
          itemBuilder: (context) {
            return CategoryConstants.categories.map((category) {
              return categoryItem(
                category['category'] ?? '', // null 체크 추가
                category['id'] ==
                    (state.selectedCategory?['id'] ?? ''), // null 체크 추가
              );
            }).toList();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(12),
            child: Text(
              state.selectedCategory?['category'] ?? '카테고리 선택', // Map 접근 방식 수정
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      );
    });
  }

  PopupMenuItem<String> categoryItem(String text, bool isSelected) {
    return PopupMenuItem<String>(
      value: text,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : null,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
