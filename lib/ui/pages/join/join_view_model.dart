// // 1. 상태만들기 Post 클래스를 상태클래스로 사용

// // 2. 뷰모델만들기

import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/data/repository/user_info_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';

class JoinViewModel extends AutoDisposeNotifier<Post?> {
  @override
  Post? build() {
    return null;
  }

  final userInfoRepository = UserInfoRepository();

  Future<dynamic> join({
    required String nickname,
    required String email,
    required String password,
    required String addressFullName,
    required String profileImageUrl,
  }) async {
    return await userInfoRepository.join(
      nickname: nickname,
      email: email,
      password: password,
      addressFullName: addressFullName,
      profileImageUrl: profileImageUrl,
    );
  }
}

// 3. 뷰모델 관리자 만들기
final joinViewModel = Provider.autoDispose((ref) {
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
