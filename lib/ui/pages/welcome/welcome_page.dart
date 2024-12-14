import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pageContent = [
    {
      'image': 'assets/picture_1.png',
      'mainText': '여행자와 구매자를 잇다,\n노마드 마켓',
      'subText': '당신의 여행이 누군가의 꿈을 현실로 만듭니다',
    },
    {
      'image': 'assets/picture_2.png',
      'mainText': '전 세계 현지 쇼핑으로 만나는\n글로벌 쇼핑 경험',
      'subText': '여행자가 현지에서 직접 구매해 배송비와 관세 부담 없이\n전 세계 현지 친구들이 당신의 퍼스널 쇼퍼가 됩니다',
    },
    {
      'image': 'assets/picture_3.png',
      'mainText': '구하기 힘든 한정판,\n노마드 마켓에서',
      'subText': '해외 현지에서만 구할 수 있는 특별한 상품을 손쉽게\n국경을 넘어 당신이 원하는 상품을 손쉽게 구매하세요',
    },
    {
      'image': 'assets/picture_4.png',
      'mainText': '여행의 즐거움에\n수익을 더하다',
      'subText': '여행하면서 간편하게 부가 수입 창출까지\n당신의 여행 가방은 이제 글로벌 마켓플레이스입니다',
    },
    {
      'image': 'assets/picture_5.png',
      'mainText': '안전한 거래,\n믿을 수 있는 플랫폼',
      'subText': '안전한 에스크로 결제와 검증된 매칭 시스템으로\n신뢰할 수 있는 안전거래를 경험하세요',
    },
    {
      'image': 'assets/picture_6.png',
      'mainText': '해외쇼핑을 넘어선\n문화 교류의 장',
      'subText': '전 세계 여행자와 구매자를 연결하는 글로벌 커뮤니티\n한국 문화의 숨은 보석을 전 세계에 연결합니다',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pageContent.length,
            itemBuilder: (context, index) {
              return _buildPage(
                image: _pageContent[index]['image']!,
                mainText: _pageContent[index]['mainText']!,
                subText: _pageContent[index]['subText']!,
              );
            },
          ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pageContent.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
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
    );
  }

  Widget _buildPage({
    required String image,
    required String mainText,
    required String subText,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(40, 100, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[800]
                    : Colors.white,
              ),
            ),
            SizedBox(height: 18),
            Text(
              subText,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[600]
                    : Colors.white70,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
