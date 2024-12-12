import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/my_profile_box.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/my_tab_app_bar.dart';

class MyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTabAppBar(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              MyProfileBox(),
              SizedBox(height: 12),
              label('나의 거래'),
              item(text: '관심목록', icon: CupertinoIcons.heart),
              item(text: '판매내역', icon: CupertinoIcons.square_list),
              item(text: '구매내역', icon: CupertinoIcons.bag),
              item(text: '거래 가계부', icon: CupertinoIcons.book),
              Divider(),
              label('환경설정'),
              item(text: '관심 도시 변경', icon: Icons.location_on_outlined),
              item(text: '언어 변경', icon: Icons.language_outlined),
              item(text: '통화 변경', icon: Icons.currency_exchange),
              Divider(),
              item(text: '자주 묻는 질문'),
              item(text: '약관 및 정책'),
            ],
          ),
        ),
      ],
    );
  }

  // label과 item 위젯은 그대로 유지
  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget item({
    required String text,
    IconData? icon,
  }) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          SnackbarUtil.showSnackBar(context, '준비중 입니다');
        },
        child: Container(
          height: 40,
          color: Colors.transparent,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
