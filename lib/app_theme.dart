import 'package:flutter/material.dart';

class AppTheme {
  // 라이트 테마 설정
  static ThemeData lightTheme() {
    return ThemeData(
      // 전체적인 밝기 설정
      brightness: Brightness.light,
      // 색상 스키마 설정 (보라색 계열)
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade900),
      // 강조색 설정
      highlightColor: Colors.purple.shade900,
      // 스캐폴드 배경색 설정 (연한 베이지)
      scaffoldBackgroundColor: const Color.fromARGB(255, 254, 248, 245),
      // 앱바 테마 설정
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 254, 248, 245),
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      // 하단 앱바 테마 설정
      bottomAppBarTheme: BottomAppBarTheme(
        color: Color.fromARGB(255, 254, 248, 245),
        shape: CircularNotchedRectangle(),
      ),
      // 버튼 테마 설정
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor:
              WidgetStateProperty.all(const Color.fromARGB(255, 254, 248, 245)),
          backgroundColor: WidgetStateProperty.all(Colors.purple.shade900),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // 입력 필드 테마 설정
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      // 페이지 전환 애니메이션 테마 설정
      pageTransitionsTheme: pageTransitionsTheme(),
      // 스낵바 테마 설정
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[100], // 스낵바 배경색 (밝은 회색)
        contentTextStyle: TextStyle(color: Colors.black), // 스낵바 텍스트 스타일 (검은색)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 스낵바 모서리 둥글게
        ),
        behavior: SnackBarBehavior.floating, // 스낵바를 화면 하단에서 띄움
        elevation: 6.0, // 스낵바 그림자 효과
      ),
    );
  }

  // 다크 테마 설정
  static ThemeData darkTheme() {
    return ThemeData(
      // 전체적인 밝기 설정
      brightness: Brightness.dark,
      // 색상 스키마 설정 (보라색 계열, 다크 모드)
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple.shade900,
        brightness: Brightness.dark,
      ),
      // 강조색 설정
      highlightColor: Colors.purple.shade900,
      // 스캐폴드 배경색 설정 (어두운 회색)
      scaffoldBackgroundColor: Colors.grey[900],
      // 앱바 테마 설정
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      // 하단 앱바 테마 설정
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.grey[900],
        shape: CircularNotchedRectangle(),
      ),
      // 버튼 테마 설정
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor: WidgetStateProperty.all(Colors.purple.shade900),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // 입력 필드 테마 설정
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      // 페이지 전환 애니메이션 테마 설정
      pageTransitionsTheme: pageTransitionsTheme(),
      // 스낵바 테마 설정
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[800], // 스낵바 배경색 (어두운 회색)
        contentTextStyle: TextStyle(color: Colors.white), // 스낵바 텍스트 스타일 (흰색)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 스낵바 모서리 둥글게
        ),
        behavior: SnackBarBehavior.floating, // 스낵바를 화면 하단에서 띄움
        elevation: 6.0, // 스낵바 그림자 효과
      ),
    );
  }

  // 페이지 전환 애니메이션 테마 설정
  static PageTransitionsTheme pageTransitionsTheme() {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      },
    );
  }
}

// 커스텀 페이지 전환 애니메이션 빌더
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 페이드 인/아웃 애니메이션 적용
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
