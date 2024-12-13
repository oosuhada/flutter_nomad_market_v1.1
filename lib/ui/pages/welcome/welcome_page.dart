import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _showSecondAnimation = false;

  @override
  void initState() {
    super.initState();
    _startSecondAnimation();
  }

  void _startSecondAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showSecondAnimation = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 1),
                builder: (context, double opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/welcome_2.png'
                      : 'assets/welcome_1.png',
                  height: 100,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 20,
              right: 20,
              child: _showSecondAnimation
                  ? TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(seconds: 2),
                      builder: (context, double opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
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
                        ],
                      ),
                    )
                  : SizedBox(),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
