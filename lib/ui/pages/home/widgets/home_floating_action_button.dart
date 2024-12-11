import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        //
        final currentIndex = ref.watch(homeViewModel);
        if (currentIndex != 0) {
          return SizedBox();
        }

        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ProductWritePage(null);
                },
              ),
            );
          },
          label: Text(
            '상품등록',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.add),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          backgroundColor: Theme.of(context).highlightColor,
          foregroundColor: Colors.white,
        );
      },
    );
  }
}
