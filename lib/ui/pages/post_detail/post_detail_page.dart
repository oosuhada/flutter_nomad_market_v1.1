import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/post_detail/widgets/post_detail_actions.dart';
import 'package:flutter_market_app/ui/pages/post_detail/widgets/post_detail_body.dart';
import 'package:flutter_market_app/ui/pages/post_detail/widgets/post_detail_bottom_sheet.dart';
import 'package:flutter_market_app/ui/pages/post_detail/widgets/post_detail_picture.dart';

class PostDetailPage extends StatelessWidget {
  PostDetailPage(this.postId);
  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PostDetailActions(postId),
        ],
      ),
      bottomSheet: PostDetailBottomSheet(
        MediaQuery.of(context).padding.bottom,
        postId,
      ),
      body: ListView(
        children: [
          PostDetailPicture(postId),
          PostDetailBody(postId),
        ],
      ),
    );
  }
}
