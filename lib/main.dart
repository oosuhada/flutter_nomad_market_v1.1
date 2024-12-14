import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)), // 로딩 화면 표시 시간
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            return WelcomePage();
          }
        },
      ),
    );
  }
}
