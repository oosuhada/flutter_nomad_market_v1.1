import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_page.dart';
import 'package:flutter_market_app/ui/pages/currency_search/currency_search_page.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:flutter_market_app/ui/pages/language_search/language_search_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/firebase_options.dart';
import 'package:flutter_market_app/ui/pages/welcome/loading_page.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_market_app/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // main.dart

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3)), // 로딩 화면 표시 시간
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            return WelcomePage(); // 시작 화면을 WelcomePage로 유지
          }
        },
      ),
      onGenerateRoute: (settings) {
        // 페이지 전환 시 페이드 애니메이션 추가
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            final page = _getPageFromRoute(settings.name!);
            return FadeTransition(opacity: animation, child: page);
          },
        );
      },
    );
  }

// 경로별로 해당 페이지를 반환
  Widget _getPageFromRoute(String route) {
    switch (route) {
      case '/language-search':
        return const LanguageSearchPage();
      case '/address-search':
        return const AddressSearchPage(selectedLanguage: 'English');
      case '/currency-search':
        return const CurrencySearchPage(
            selectedLanguage: 'USD', selectedAddress: '123 Main St');
      case '/join':
        return JoinPage(
          language: 'Selected Language',
          address: 'Selected Address',
          currency: 'Selected Currency',
        );
      default:
        return const WelcomePage();
    }
  }
}

// 커스텀 애니메이션을 위한 PageRouteTransition 위젯
class PageRouteTransition extends StatelessWidget {
  final Widget child;
  const PageRouteTransition({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PageTransition(
      child: child,
    );
  }
}

class PageTransition extends StatefulWidget {
  final Widget child;
  const PageTransition({super.key, required this.child});

  @override
  State<PageTransition> createState() => _PageTransitionState();
}

class _PageTransitionState extends State<PageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // 애니메이션 시간을 1초로 늘림
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // 부드러운 시작을 위해 easeIn 커브 사용
    );

    // 약간의 지연 후 애니메이션 시작
    Future.delayed(Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
