import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/user_profile_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfileBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final user = ref.watch(userGlobalViewModel);

      return Row(
        children: [
          user == null
              ? SizedBox()
              : UserProfileImage(
                  dimension: 50,
                  imgUrl: user.profileImage.url,
                ),
          SizedBox(width: 10),
          Expanded(
            child: user == null
                ? SizedBox()
                : Text(
                    user.nickname,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () {
              SnackbarUtil.showSnackBar(
                context,
                '준비중입니다',
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: Text(
                '프로필 수정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
