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
      scaffoldBackgroundColor:
          const Color.fromARGB(255, 254, 248, 245), // 앱바 배경색과 동일하게 설정
      hintColor: Colors.grey[800],
      cardColor: Colors.grey[400],
      focusColor: Colors.grey[400],
      hoverColor: Colors.grey[400],
      shadowColor: Colors.grey[400],
      splashColor: Colors.grey[400],
      unselectedWidgetColor: Colors.grey[400],
      canvasColor: Colors.grey[900],
      dividerColor: Colors.grey[800],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.purple.shade900,
        selectionColor: Colors.purple.shade900,
        selectionHandleColor: Colors.purple.shade900,
      ),
      primaryColorDark: Colors.grey[400],
      primaryColorLight: Colors.grey[400],
      disabledColor: Colors.grey[600],
      indicatorColor: Colors.purple.shade900,
      secondaryHeaderColor: Colors.grey[800],
      dialogBackgroundColor: Colors.grey[800],
      applyElevationOverlayColor: true,
      // 앱바 테마 설정
      primaryColor: Color.fromARGB(255, 254, 248, 245),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 254, 248, 245), // 앱바 배경색과 동일하게 설정
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
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
        backgroundColor: Colors.white, // 스낵바 배경색 (어두운 회색)
        contentTextStyle: TextStyle(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
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
      primaryColor: Colors.grey[900], // 앱바 배경색과 동일하게 설정
      hintColor: Colors.grey[400],
      cardColor: Colors.grey[800],
      focusColor: Colors.grey[800],
      hoverColor: Colors.grey[800],
      shadowColor: Colors.grey[800],
      splashColor: Colors.grey[800],
      unselectedWidgetColor: Colors.grey[400],
      canvasColor: Colors.grey[900],
      dividerColor: Colors.grey[800],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.purple.shade900,
        selectionColor: Colors.purple.shade900,
        selectionHandleColor: Colors.purple.shade900,
      ),
      primaryColorDark: Colors.grey[900],
      primaryColorLight: Colors.grey[900],
      disabledColor: Colors.grey[600],
      indicatorColor: Colors.purple.shade900,
      secondaryHeaderColor: Colors.grey[800],
      dialogBackgroundColor: Colors.grey[800],
      applyElevationOverlayColor: true,

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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
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
        backgroundColor: Colors.black, // 스낵바 배경색 (어두운 회색)
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
      ),
    );
  }

  static Color lightSnackbarBackground = Colors.grey[400]!;
  static Color darkSnackbarBackground = Colors.transparent;
  static Color lightSnackbarText = Colors.black;
  static Color darkSnackbarText = Colors.white;
  static double snackbarBorderRadius = 8.0;
  static EdgeInsets snackbarPadding =
      const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  static double snackbarTextSize = 14.0;

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
