// // 1. 상태만들기 Post 클래스를 상태클래스로 사용

// // 2. 뷰모델만들기

import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';

// bool? 타입을 사용하여 join 결과를 나타냄
class JoinViewModel extends AutoDisposeNotifier<bool?> {
  @override
  bool? build() {
    return null; // 초기 상태는 null
  }

  final userInfoRepository = UserRepository();

  Future<bool?> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
    required String language,
    required String currency,
  }) async {
    state = null; // 작업 시작 시 상태를 null로 설정
    final result = await userInfoRepository.join(
      nickname: nickname,
      email: email,
      password: password,
      addressFullName: addressFullName,
      profileImageUrl: profileImageUrl,
      language: language,
      currency: currency,
    );
    state = result; // 결과를 상태에 저장
    return result;
  }
}

// 뷰모델 Provider 수정
final joinViewModel = NotifierProvider.autoDispose<JoinViewModel, bool?>(() {
  return JoinViewModel();
});


// // 3. 뷰모델 관리자 만들기
// final joinViewModel =
//     NotifierProvider.autoDispose<JoinViewModel, FileModel?>(() {
//   return JoinViewModel();
// });




// // 1. 상태클래스 만들기 => X

// // 2. 뷰모델 만들기
// import 'package:flutter_market_app/data/repository/user_info_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class JoinViewModel {
//   final userInfoRepository = UserInfoRepository();

//   Future<bool?> join({
//     required String nickname,
//     required String email,
//     required String password,
//     required String addressFullName,
//     required String profileImageUrl,
//   }) async {
//     return await userInfoRepository.join(
//       nickname: nickname,
//       email: email,
//       password: password,
//       addressFullName: addressFullName,
//       profileImageUrl: profileImageUrl,
//     );
//   }

//   // void uploadImage({
//   // }) async {

//   // }
// }

// // 3. 뷰모델 관리자 만들기
// final joinViewModel = Provider.autoDispose((ref) {
//   return JoinViewModel();
// });
