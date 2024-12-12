import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Spacer(),
                Image.asset(
                  'assets/welcome.png',
                  height: 100,
                ),
                SizedBox(height: 50),
                Text(
                  '내 손안의 글로벌 커머스',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '지금 전 세계 도시를 선택하고 시작해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return AddressSearchPage();
                      },
                    ));
                  },
                  child: Text('시작하기'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ));
                  },
                  child: Container(
                    height: 50,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      '이미 계정이 있나요? 로그인',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
