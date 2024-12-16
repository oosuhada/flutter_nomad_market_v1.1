import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/data/model/product_category.dart';

// 홈 탭의 팝업 버튼 위젯 (카테고리, 거래방식, 상품유형 선택에 사용)
class HomeTabPopupButton extends ConsumerWidget {
  // 현재 선택된 값
  final String selectedValue;
  // 값이 변경될 때 호출될 콜백
  final ValueChanged<String> onChanged;
  // 선택 가능한 항목 리스트 (null인 경우 카테고리 리스트 사용)
  final List<String>? items;

  const HomeTabPopupButton({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("===== HomeTabPopupButton build 시작 =====");

    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        position: PopupMenuPosition.under,
        // 다크모드 대응 배경색
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (String value) {
          print("팝업 메뉴 항목 선택: $value");
          onChanged(value); // 상위 위젯으로 선택값 전달
        },
        // 팝업 메뉴 아이템 빌더
        itemBuilder: (context) {
          // items가 있으면 해당 리스트로 메뉴 구성
          if (items != null) {
            print("커스텀 아이템 리스트 사용");
            return items!.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList();
          }

          // items가 없으면 카테고리 리스트로 메뉴 구성
          print("카테고리 리스트 사용");
          return CategoryConstants.categories.map((category) {
            return categoryItem(
              context,
              category['category'] ?? '',
              false, // 선택 상태는 상위 위젯에서 관리
            );
          }).toList();
        },
        // 버튼 UI
        child: Container(
          decoration: BoxDecoration(
            // 다크모드 대응 배경색
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
              // 선택된 값 표시
              Text(
                selectedValue.isNotEmpty ? selectedValue : '카테고리 선택',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  // 다크모드 대응 텍스트 색상
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 1),
              // 드롭다운 아이콘
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

  // 카테고리 메뉴 아이템 스타일링
  PopupMenuItem<String> categoryItem(
    BuildContext context,
    String text,
    bool isSelected,
  ) {
    print("카테고리 아이템 생성: $text (선택됨: $isSelected)");
    return PopupMenuItem<String>(
      value: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            // 선택 상태와 다크모드에 따른 텍스트 색상
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
