import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_app_bar.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/home_tab_popupbutton.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';

// 홈 탭 화면을 구성하는 StatefulWidget
class HomeTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print("===== HomeTab initState =====");
    Future.microtask(() async {
      try {
        print("데이터 로드 시작");
        final vm = ref.read(homeTabViewModel.notifier);
        await vm.loadAllProducts();
        print("데이터 로드 완료");
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        print("데이터 로드 실패: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = '데이터 로드 중 오류가 발생했습니다';
          });
        }
      }
    });
  }

  // 초기 데이터 로드 메서드
  Future<void> _initializeData() async {
    print("===== HomeTab 데이터 초기화 시작 =====");
    try {
      setState(() => _isLoading = true);

      // 홈탭 뷰모델 접근
      final state = ref.read(homeTabViewModel);
      final vm = ref.read(homeTabViewModel.notifier);
      print("HomeTabViewModel 접근");

      // 현재 상태 확인
      print("현재 상태 확인:");
      print("Categories 존재 여부: ${state.categories.isNotEmpty}");
      print("Categories 내용: ${state.categories}");

      // 카테고리가 선택되지 않은 경우 기본값 설정
      if (state.selectedCategory == null && state.categories.isNotEmpty) {
        print("선택된 카테고리 없음 - 기본값 설정");
        vm.onCategorySelected(state.categories.first);
      }

      setState(() => _isLoading = false);
      print("초기화 완료");
    } catch (e, stackTrace) {
      print("===== 초기화 중 에러 발생 =====");
      print("에러 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '데이터 로드 중 오류가 발생했습니다';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("===== HomeTab build 시작 =====");

    try {
      // 홈탭 상태 감시
      final state = ref.watch(homeTabViewModel);
      final vm = ref.read(homeTabViewModel.notifier);
      print("HomeTabViewModel 상태 감시 중");

      // 로딩 상태 처리
      if (_isLoading) {
        print("로딩 중 표시");
        return const Center(child: CircularProgressIndicator());
      }

      // 에러 상태 처리
      if (_errorMessage.isNotEmpty) {
        print("에러 메시지 표시: $_errorMessage");
        return Center(child: Text(_errorMessage));
      }

      // 선택된 카테고리 이름 안전하게 가져오기
      final categoryName = state.selectedCategory?['category'] ?? '카테고리';
      print("선택된 카테고리명: $categoryName");

      // 메인 UI 구성
      return SizedBox.expand(
        child: Column(
          children: [
            HomeTabAppBar(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // 카테고리 선택 버튼
                  HomeTabPopupButton(
                    selectedValue: categoryName,
                    items: state.categories.isNotEmpty
                        ? state.categories
                        : ['카테고리'],
                    onChanged: (String newValue) {
                      print("카테고리 변경 시도: $newValue");
                      try {
                        vm.onCategorySelected(
                            newValue); // onCategorySelected 호출 수정
                        print("카테고리 변경 성공");
                      } catch (e) {
                        print("카테고리 변경 실패: $e");
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // 거래방식 선택 버튼
                  HomeTabPopupButton(
                    selectedValue: '거래방식',
                    items: ['거래방식', '직거래', '택배거래'],
                    onChanged: (String? newValue) {
                      print("거래방식 변경: $newValue");
                    },
                  ),
                  const SizedBox(width: 8),
                  // 상품 유형 선택 버튼
                  HomeTabPopupButton(
                    selectedValue: '모든상품',
                    items: ['모든상품', '새상품', '중고상품'],
                    onChanged: (String? newValue) {
                      print("상품 유형 변경: $newValue");
                    },
                  ),
                  const Spacer(),
                  // 정렬 버튼
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () {
                      print("정렬 버튼 클릭");
                    },
                  ),
                ],
              ),
            ),
            // 게시글 목록 표시
            Expanded(
              child: HomeTabListView(),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print("===== UI 빌드 중 에러 발생 =====");
      print("에러 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      return const Center(
        child: Text('화면을 불러오는 중 오류가 발생했습니다'),
      );
    }
  }

  @override
  void dispose() {
    print("===== HomeTab dispose =====");
    super.dispose();
  }
}
