import 'package:flutter/material.dart';

class HomeTabPopupButton extends StatelessWidget {
  final String selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const HomeTabPopupButton({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        onSelected: onChanged,
        itemBuilder: (context) {
          return items.map((e) {
            return categoryItem(context, e, e == selectedValue);
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
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
              vertical: 10, horizontal: 20), // Adjusted padding
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedValue.isNotEmpty ? selectedValue : '카테고리 선택',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Adjusted font size
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              SizedBox(width: 2), // Adjusted SizedBox width
              Icon(
                Icons.arrow_drop_down,
                size: 20, // Adjusted icon size
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
      BuildContext context, String text, bool isSelected) {
    return PopupMenuItem<String>(
      value: text,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
    );
  }
}