// post_detail_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailBody extends StatelessWidget {
  PostDetailBody(this.postId);

  final String postId; // int에서 String으로 변경

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final post = ref.watch(postDetailViewModel(postId));
      if (post == null) {
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
            profileArea(post),
            Divider(height: 30),
            Text(
              post.translatedTitle ?? post.originalTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${post.category} - ${DateTimeUtils.formatString(post.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              post.translatedDescription ?? post.originalDescription,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    });
  }

  Row profileArea(Post post) {
    return Row(
      children: [
        UserProfileImage(
          dimension: 50,
          imgUrl: post.userProfileImageUrl,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userNickname,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                post.userHomeAddress,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
