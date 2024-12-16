// post_detail_picture.dart
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailPicture extends StatelessWidget {
  PostDetailPicture(this.postId);
  final String postId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(postDetailViewModel(postId));
      final images = state?.images ?? [];
      return SizedBox(
        height: 500,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(
              images[index],
              fit: BoxFit.cover,
            );
          },
        ),
      );
    });
  }
}
