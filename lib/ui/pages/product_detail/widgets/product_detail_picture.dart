import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/product_detail/product_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailPicture extends StatelessWidget {
  ProductDetailPicture(this.productId);
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(productDetailViewModel(productId));
      final imageFiles = state?.imageFiles ?? [];
      return SizedBox(
        height: 500,
        child: PageView.builder(
          itemCount: imageFiles.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageFiles[index].url,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    });
  }
}
