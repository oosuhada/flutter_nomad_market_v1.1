import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/city_selection.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/currency_setting.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/language_setting.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/my_profile_box.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/my_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/purchase_history.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/sales_history.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/transaction_account.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/my_tab/widgets/wishlist.dart';

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
                nextPage: WishListPage(),
              ),
              item(
                context: context,
                text: '판매내역',
                icon: CupertinoIcons.square_list,
                nextPage: SalesHistoryPage(),
              ),
              item(
                context: context,
                text: '구매내역',
                icon: CupertinoIcons.bag,
                nextPage: PurchaseHistoryPage(),
              ),
              item(
                context: context,
                text: '거래 가계부',
                icon: CupertinoIcons.book,
                nextPage: TransactionAccountPage(),
              ),
              Divider(),
              label('환경설정'),
              item(
                context: context,
                text: '관심 도시 변경',
                icon: Icons.location_on_outlined,
                nextPage: CitySelection(
                  onCitySelect: (String) {},
                ),
              ),
              item(
                context: context,
                text: '언어 변경',
                icon: Icons.language_outlined,
                nextPage: LanguageSetting(
                  onLanguageSelect: (String) {},
                ),
              ),
              item(
                context: context,
                text: '통화 변경',
                icon: Icons.currency_exchange,
                nextPage: CurrencySetting(
                  onCurrencySelect: (String) {},
                ),
              ),
              Divider(),
              item(
                context: context,
                text: '자주 묻는 질문',
                nextPage: WishListPage(),
              ),
              item(
                context: context,
                text: '약관 및 정책',
                nextPage: WishListPage(),
              ),
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
    required Widget nextPage,
    required BuildContext context,
    required String text,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return nextPage;
          },
        ));
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
  }
}
