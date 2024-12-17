import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class JoinViewModel extends AutoDisposeNotifier<bool?> {
  @override
  bool? build() {
    return null;
  }

  final userInfoRepository = UserRepository();

  // 계정 생성 메서드 추가
  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await userInfoRepository.createAuthAccount(
        email: email,
        password: password,
      );
      return credential != null;
    } catch (e) {
      print('계정 생성 오류: $e');
      return false;
    }
  }

  Future<bool?> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
    required String language,
    required String currency,
  }) async {
    state = null;
    final result = await userInfoRepository.join(
      nickname: nickname,
      email: email,
      password: password,
      addressFullName: addressFullName,
      profileImageUrl: profileImageUrl,
      language: language,
      currency: currency,
    );
    state = result;
    return result;
  }
}

final joinViewModel = NotifierProvider.autoDispose<JoinViewModel, bool?>(() {
  return JoinViewModel();
});
