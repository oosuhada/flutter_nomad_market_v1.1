import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_view_model.dart';
import 'package:flutter_market_app/data/model/product_category.dart';

class HomeTabPopupButton extends ConsumerWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final List<String>? items; // items 파라미터 추가

  const HomeTabPopupButton({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.items, // 생성자에 items 파라미터 추가
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productWriteViewModel(null));
    final vm = ref.read(productWriteViewModel(null).notifier);

    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        position: PopupMenuPosition.under,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (String value) {
          onChanged(value);
          // items가 있는 경우에만 카테고리 선택 처리
          if (items == null) {
            vm.onCategorySelected(value);
          }
        },
        itemBuilder: (context) {
          // items가 제공된 경우 해당 items로 메뉴 아이템 생성
          if (items != null) {
            return items!.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList();
          }
          // 카테고리 메뉴 아이템 생성 (기존 로직)
          return state.categories.map((ProductCategory category) {
            return categoryItem(
              context,
              category.category,
              category.id == state.selectedCategory?.id,
            );
          }).toList();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedValue.isNotEmpty ? selectedValue : '카테고리 선택',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> categoryItem(
    BuildContext context,
    String text,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
    );
  }
}
