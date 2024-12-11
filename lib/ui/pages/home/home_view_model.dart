// 1. 상태클래스 만들기
// 2. 뷰모델 만들기
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends AutoDisposeNotifier<int> {
  @override
  int build() {
    return 0;
  }

  void onIndexChanged(int newIndex) {
    state = newIndex;
  }
}

// 3. 뷰모델 관리자 만들기

final homeViewModel = NotifierProvider.autoDispose<HomeViewModel, int>(() {
  return HomeViewModel();
});
