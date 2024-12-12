import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/chat_detail/chat_detail_page.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade900),
        highlightColor: Colors.purple.shade900,
        scaffoldBackgroundColor: const Color.fromARGB(255, 254, 248, 245),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color.fromARGB(255, 254, 248, 245),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                WidgetStatePropertyAll(Color.fromARGB(255, 254, 248, 245)),
            backgroundColor: WidgetStatePropertyAll(Colors.purple.shade900),
            minimumSize: WidgetStatePropertyAll(Size.fromHeight(52)),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: WidgetStatePropertyAll(
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
            color: Colors.grey,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: MaterialStateOutlineInputBorder.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              );
            }
            if (states.contains(WidgetState.error)) {
              return OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.red[100]!,
                  width: 2,
                ),
              );
            }
            return OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            );
          }),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple.shade200,
          brightness: Brightness.dark,
        ),
        highlightColor: Colors.purple.shade900,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.grey[900],
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            backgroundColor: WidgetStatePropertyAll(Colors.purple.shade900),
            minimumSize: WidgetStatePropertyAll(Size.fromHeight(52)),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.5)),
            elevation: WidgetStatePropertyAll(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: MaterialStateOutlineInputBorder.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[400]!,
                  width: 2,
                ),
              );
            }
            if (states.contains(WidgetState.error)) {
              return OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.red[300]!,
                  width: 2,
                ),
              );
            }
            return OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[600]!,
                width: 1,
              ),
            );
          }),
        ),
      ),
      themeMode: ThemeMode.system,
      home: WelcomePage(),
    );
  }
}
