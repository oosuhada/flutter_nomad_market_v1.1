import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';

class JoinState {
  final bool isLoading;
  final String? error;
  final bool? joinSuccess;
  final File? imageFile;
  final String? imageUrl;

  JoinState({
    this.isLoading = false,
    this.error,
    this.joinSuccess,
    this.imageFile,
    this.imageUrl,
  });

  JoinState copyWith({
    bool? isLoading,
    String? error,
    bool? joinSuccess,
    File? imageFile,
    String? imageUrl,
  }) {
    return JoinState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      joinSuccess: joinSuccess ?? this.joinSuccess,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class JoinViewModel extends AutoDisposeNotifier<JoinState> {
  final userInfoRepository = UserRepository();

  @override
  JoinState build() {
    return JoinState();
  }

  // 프로필 이미지 업데이트
  void updateProfileImage(File? file, String? url) {
    state = state.copyWith(
      imageFile: file,
      imageUrl: url,
    );
  }

  // 에러 다이얼로그 표시 로직
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text('오류', style: theme.textTheme.titleSmall),
          content: Text(message,
              style: TextStyle(
                  color: theme.listTileTheme.textColor, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인',
                  style: TextStyle(
                      color: theme.colorScheme.primary, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // 회원가입 실행 로직
  Future<void> onJoin({
    required BuildContext context,
    required String email,
    required String password,
    required String nickname,
    required String selectedAddress,
    required String selectedLanguage,
    required String selectedCurrency,
  }) async {
    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      SnackbarUtil.showSnackBar(context, '필수 항목을 모두 입력해주세요');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await userInfoRepository.join(
        nickname: nickname,
        email: email,
        password: password,
        addressFullName: selectedAddress,
        profileImageUrl: state.imageUrl ?? '',
        language: selectedLanguage.split(' ')[0].toLowerCase(),
        currency: selectedCurrency.split(' ')[0],
      );

      if (result == true) {
        state = state.copyWith(joinSuccess: true);

        await _handleSuccessfulJoin(context);
      } else {
        state = state.copyWith(
          error: '회원가입에 실패했습니다',
          joinSuccess: false,
        );
        SnackbarUtil.showSnackBar(context, '회원가입에 실패했습니다');
      }
    } catch (e, stackTrace) {
      print("회원가입 중 오류 발생: $e");
      print("스택트레이스: $stackTrace");
      state = state.copyWith(
        error: '회원가입 중 오류가 발생했습니다',
        joinSuccess: false,
      );
      SnackbarUtil.showSnackBar(context, '회원가입 중 오류가 발생했습니다');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 성공적인 회원가입 처리
  Future<void> _handleSuccessfulJoin(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('회원가입이 성공적으로 완료되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(Duration(seconds: 2));

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );
            var scaleAnimation = Tween(begin: 0.1, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );
            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  // 데이터 포맷팅 유틸리티
  static String formatLanguage(String language) {
    final languageMap = {
      "한국어": "ko",
      "English": "en",
    };
    return languageMap[language] ?? "ko";
  }

  static String formatCurrency(String currency) {
    return currency.split(' ')[0];
  }
}

final joinViewModel =
    NotifierProvider.autoDispose<JoinViewModel, JoinState>(() {
  return JoinViewModel();
});
