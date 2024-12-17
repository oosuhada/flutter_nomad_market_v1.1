import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// HomeTab의 상태를 관리하는 클래스
class HomeTabState {
  final List<Address> addresses;
  final List<PostSummary> posts;
  final List<String> categories;
  final Map<String, String>? selectedCategory;

  const HomeTabState({
    required this.addresses,
    required this.posts,
    required this.categories,
    this.selectedCategory,
  });

  HomeTabState copyWith({
    List<Address>? addresses,
    List<PostSummary>? posts,
    List<String>? categories,
    Map<String, String>? selectedCategory,
  }) {
    return HomeTabState(
      addresses: addresses ?? this.addresses,
      posts: posts ?? this.posts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// HomeTab의 ViewModel 클래스
class HomeTabViewModel extends StateNotifier<HomeTabState> {
  // 생성자에서 ref를 받아 UserGlobalViewModel에 접근
  HomeTabViewModel(this.ref)
      : super(HomeTabState(
          addresses: [],
          posts: [],
          categories: CategoryConstants.categories
              .map((category) => category['category']!)
              .toList(),
          selectedCategory: null,
        )) {
    print("===== HomeTabViewModel 초기화 =====");
    _initUserData();
  }

  final Ref ref;
  final addressRepository = AddressRepository();
  final postRepository = PostRepository();

  // 사용자 정보 초기화
  void _initUserData() {
    print("===== HomeTabViewModel 사용자 정보 확인 =====");
    try {
      final user = ref.read(userGlobalViewModel);
      if (user != null) {
        print("로그인된 사용자 정보:");
        print("- userId: ${user.userId}");
        print("- nickname: ${user.nickname}");
      } else {
        print("로그인된 사용자 정보 없음");
      }
    } catch (e) {
      print("사용자 정보 확인 중 에러 발생: $e");
    }
  }

  // 카테고리 선택 처리
  void onCategorySelected(String category) {
    print("카테고리 선택: $category");
    try {
      final selectedCategory = CategoryConstants.categories.firstWhere(
        (cat) => cat['category'] == category,
        orElse: () => CategoryConstants.categories.first,
      );
      state = state.copyWith(selectedCategory: selectedCategory);
      print("홈탭 카테고리 업데이트 완료: $category");
    } catch (e) {
      print("홈탭 카테고리 선택 에러: $e");
    }
  }

  // 주소 목록 조회
  Future<void> fetchAddresses() async {
    print("주소 목록 가져오기 시작");
    try {
      final user = ref.read(userGlobalViewModel);
      final userId = user?.userId ?? 'defaultUserId';
      final addresses = await addressRepository.getMyAddressByEmail(userId);
      state = state.copyWith(addresses: addresses);
      print("주소 목록 업데이트 완료: ${addresses.length}. ${addresses.first.city}");
    } catch (e) {
      print("주소 목록 조회 중 에러 발생: $e");
    }
  }

  // 기본 주소 업데이트
  Future<void> updateDefaultAddress(String cityName) async {
    print("기본 주소 업데이트 시작: $cityName");
    try {
      final updatedAddresses = state.addresses.map((address) {
        return address.copyWith(defaultYn: address.city == cityName);
      }).toList();

      state = state.copyWith(addresses: updatedAddresses);
      await fetchPosts();
      print("기본 주소 업데이트 완료");
    } catch (e) {
      print("기본 주소 업데이트 중 에러 발생: $e");
    }
  }

  // 게시글 목록 조회
  Future<void> fetchPosts() async {
    print("게시글 목록 가져오기 시작");
    try {
      if (state.addresses.isEmpty) {
        print("주소 목록이 비어있음");
        return;
      }

      final defaultAddress = state.addresses.firstWhere(
        (e) => e.defaultYn ?? false,
        orElse: () => state.addresses.first,
      );

      final summaries =
          await postRepository.getPostSummaryList(defaultAddress.city);
      if (summaries != null) {
        state = state.copyWith(posts: summaries);
        print("게시글 목록 업데이트 완료: ${summaries.length}개");
      }
    } catch (e) {
      print("게시글 목록 조회 중 에러 발생: $e");
    }
  }
}

// Provider 정의 - 파일 최상위 레벨에 위치
final homeTabViewModel =
    StateNotifierProvider<HomeTabViewModel, HomeTabState>((ref) {
  return HomeTabViewModel(ref);
});
