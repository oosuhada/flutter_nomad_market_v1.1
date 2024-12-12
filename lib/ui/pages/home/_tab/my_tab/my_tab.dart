import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              item(
                  context: context,
                  text: '관심목록',
                  icon: CupertinoIcons.heart,
                  route: '/wishlist'),
              item(
                  context: context,
                  text: '판매내역',
                  icon: CupertinoIcons.square_list,
                  route: '/sales_history'),
              item(
                  context: context,
                  text: '구매내역',
                  icon: CupertinoIcons.bag,
                  route: '/purchase_history'),
              item(
                  context: context,
                  text: '거래 가계부',
                  icon: CupertinoIcons.book,
                  route: '/transaction_account'),
              Divider(),
              label('환경설정'),
              item(
                  context: context,
                  text: '관심 도시 변경',
                  icon: Icons.location_on_outlined,
                  route: '/city_selection'),
              item(
                  context: context,
                  text: '언어 변경',
                  icon: Icons.language_outlined,
                  route: '/language_selection'),
              item(
                  context: context,
                  text: '통화 변경',
                  icon: Icons.currency_exchange,
                  route: '/currency_selection'),
              Divider(),
              item(
                  context: context,
                  text: '자주 묻는 질문',
                  route: '/frequently_asked_questions'),
              item(
                  context: context,
                  text: '약관 및 정책',
                  route: '/terms_and_policies'),
            ],
          ),
        ),
      ],
    );
  }

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
    required BuildContext context,
    required String text,
    IconData? icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => navigateToPage(context, route),
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
  }

  void navigateToPage(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
