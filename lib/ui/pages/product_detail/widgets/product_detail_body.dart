import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/product.dart';
import 'package:flutter_market_app/ui/pages/product_detail/product_detail_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailBody extends StatelessWidget {
  ProductDetailBody(this.productId);

  final int productId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(productDetailViewModel(productId));
      if (state == null) {
        return SizedBox();
      }

      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 500,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileArea(state),
            Divider(height: 30),
            Text(
              state.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${state.category.category} - ${DateTimeUtils.formatString(state.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              state.content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    });
  }

  Row profileArea(Product product) {
    return Row(
      children: [
        UserProfileImage(
          dimension: 50,
          imgUrl: product.user.profileImage.url,
        ),
        SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.user.nickname,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              product.address.displayName,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
