import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade900),
      highlightColor: Colors.purple.shade900,
      scaffoldBackgroundColor: const Color.fromARGB(255, 254, 248, 245),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 254, 248, 245),
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Color.fromARGB(255, 254, 248, 245),
        shape: CircularNotchedRectangle(),
      ),
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
      pageTransitionsTheme:
          pageTransitionsTheme(), // CustomPageTransitionBuilder 추가
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple.shade900,
        brightness: Brightness.dark,
      ),
      highlightColor: Colors.purple.shade900,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.grey[900],
        shape: CircularNotchedRectangle(),
      ),
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
      pageTransitionsTheme:
          pageTransitionsTheme(), // CustomPageTransitionBuilder 추가
    );
  }

  static PageTransitionsTheme pageTransitionsTheme() {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      },
    );
  }
}

// 페이지 전환 애니메이션 커스터마이징
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
