import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class HomeTabViewModel extends AutoDisposeNotifier<HomeTabState> {
  final addressRepository = AddressRepository();
  final postRepository = PostRepository();

  @override
  HomeTabState build() {
    print("===== HomeTabViewModel 초기화 =====");

    fetchAddresses().then((_) {
      fetchPosts();
    });

    return HomeTabState(
      addresses: [],
      posts: [],
      categories: CategoryConstants.categories
          .map((category) => category['category']!)
          .toList(),
      selectedCategory: null,
    );
  }

  Future<void> fetchAddresses() async {
    print("주소 목록 가져오기 시작");
    final userId = 'currentUserId'; // 현재 로그인한 사용자의 ID를 가져오는 로직 추가
    final addresses = await addressRepository.getMyAddressList(userId);
    state = state.copyWith(addresses: addresses ?? []);
    print("주소 목록 업데이트 완료: ${addresses?.length ?? 0}개");
  }

  Future<void> updateDefaultAddress(String cityName) async {
    print("기본 주소 업데이트 시작: $cityName");
    final updatedAddresses = state.addresses.map((address) {
      return address.copyWith(defaultYn: false);
    }).toList();

    final index =
        updatedAddresses.indexWhere((address) => address.city == cityName);

    if (index != -1) {
      updatedAddresses[index] =
          updatedAddresses[index].copyWith(defaultYn: true);
      state = state.copyWith(addresses: updatedAddresses);
      await fetchPosts();
      print("기본 주소 업데이트 완료");
    } else {
      print('해당 도시를 찾을 수 없습니다: $cityName');
    }
  }

  Future<void> fetchPosts() async {
    print("게시글 목록 가져오기 시작");
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
  }

  void onCategorySelected(String category) {
    print("===== 홈탭 카테고리 선택 =====");
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
}

final homeTabViewModel =
    NotifierProvider.autoDispose<HomeTabViewModel, HomeTabState>(() {
  return HomeTabViewModel();
});
