import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeFloatingActionButton extends ConsumerStatefulWidget {
  @override
  _HomeFloatingActionButtonState createState() =>
      _HomeFloatingActionButtonState();
}

class _HomeFloatingActionButtonState
    extends ConsumerState<HomeFloatingActionButton> {
  bool _isMenuOpen = false;

  void _showWritingOptions() {
    setState(() {
      _isMenuOpen = true;
    });
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100,
        MediaQuery.of(context).size.height - 290,
        MediaQuery.of(context).size.width - 10,
        MediaQuery.of(context).size.height - 200,
      ),
      items: [
        PopupMenuItem(
          child: Container(
            child: Row(
              children: [
                Icon(Icons.request_page),
                SizedBox(width: 8),
                Text(
                  '물품 의뢰하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onTap: () {
            _navigateToProductWritePage(true);
          },
        ),
        PopupMenuItem(
          child: Container(
            child: Row(
              children: [
                Icon(Icons.sell),
                SizedBox(width: 8),
                Text(
                  '내 물건 판매',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onTap: () {
            _navigateToProductWritePage(false);
          },
        ),
      ],
    ).then((value) {
      setState(() {
        _isMenuOpen = false;
      });
    });
  }

  void _navigateToProductWritePage(bool isRequesting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductWritePage(isRequesting: isRequesting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeViewModel);
    if (currentIndex != 0) {
      return SizedBox();
    }

    return SizedBox(
      height: 52,
      child: FloatingActionButton.extended(
        onPressed: _showWritingOptions,
        extendedPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 0),
        label: Text(
          '상품등록',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(_isMenuOpen ? Icons.close : Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _isMenuOpen
            ? Colors.grey.shade900
            : Theme.of(context).highlightColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
