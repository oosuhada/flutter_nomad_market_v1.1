import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/address_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/data/repository/post_summary_repository.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider 정의 - 최상위 레벨로 이동
final postRepositoryProvider = Provider((ref) => PostRepository());
final addressRepositoryProvider = Provider((ref) => AddressRepository());
final postSummaryRepositoryProvider =
    Provider((ref) => PostSummaryRepository());

/// HomeTab의 상태를 관리하는 클래스
/// addresses: 사용자의 주소 목록
/// posts: 현재 선택된 지역의 게시글 목록
/// categories: 상품 카테고리 목록
/// selectedCategory: 현재 선택된 카테고리 정보
class HomeTabState {
  final List<Address> addresses;
  final List<PostSummary> posts;
  final List<String> categories;
  final Map<String, String>? selectedCategory;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const HomeTabState({
    required this.addresses,
    required this.posts,
    required this.categories,
    this.selectedCategory,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  HomeTabState copyWith({
    List<Address>? addresses,
    List<PostSummary>? posts,
    List<String>? categories,
    Map<String, String>? selectedCategory,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return HomeTabState(
      addresses: addresses ?? this.addresses,
      posts: posts ?? this.posts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

/// HomeTab의 ViewModel 클래스
/// UserRepository는 userGlobalViewModel을 통해 접근
/// PostRepository는 직접 의존성 주입 받음
class HomeTabViewModel extends StateNotifier<HomeTabState> {
  final Ref ref;
  final PostRepository postRepository;
  final AddressRepository addressRepository;
  static const int pageSize = 20;
  final PostSummaryRepository postSummaryRepository;

  HomeTabViewModel(this.ref, this.postRepository, this.addressRepository,
      this.postSummaryRepository)
      : super(HomeTabState(
          addresses: [],
          posts: [],
          categories: CategoryConstants.categories
              .map((category) => category['category']!)
              .toList(),
          selectedCategory: null,
          isLoading: false,
          hasMore: true,
        )) {
    print("===== HomeTabViewModel 초기화 =====");
    print("- PostRepository 주입됨");
    print("- 초기 상태 설정 완료");
    _initUserData();
  }

  /// 사용자 정보 초기화 및 검증
  void _initUserData() {
    print("===== HomeTabViewModel 사용자 정보 초기화 =====");
    try {
      final user = ref.read(userGlobalViewModel);
      if (user != null) {
        print("로그인된 사용자 확인:");
        print("- userId: ${user.userId}");
        print("- nickname: ${user.nickname}");
        print("- address: ${user.address.fullNameKR}");

        // 사용자 주소 정보가 있으면 초기 데이터 로드
        if (user.address.fullNameKR.isNotEmpty) {
          _loadInitialData(user.address.fullNameKR);
        }
      } else {
        print("로그인된 사용자 정보 없음 - 초기 데이터 로드 건너뜀");
      }
    } catch (e, stack) {
      print("사용자 정보 초기화 중 에러 발생:");
      print("- 에러: $e");
      print("- 스택트레이스: $stack");
    }
  }

  /// 초기 데이터 로드 (주소 기반 게시글)
  Future<void> _loadInitialData(String defaultAddress) async {
    print("===== 초기 데이터 로드 시작 =====");
    print("기본 주소: $defaultAddress");

    try {
      final posts =
          await postSummaryRepository.getPostSummaryList(defaultAddress);
      if (posts != null) {
        // 주소 정보 파싱 및 처리
        final addressParts = defaultAddress.split(',');
        final cityWithState = addressParts[0].trim();
        final country = addressParts.length > 1 ? addressParts[1].trim() : '';

        // Address.processLocationInfo를 사용하여 주소 정보 정제
        final krLocation =
            Address.processLocationInfo(cityWithState, country, isKorean: true);

        // 서비스 가능 여부 확인
        final isServiceAvailable = Address.checkServiceAvailability(
            krLocation['city']!, krLocation['country']!);

        state = state.copyWith(
          addresses: [
            Address(
              id: '',
              fullNameKR: defaultAddress,
              fullNameEN: '', // 영문 주소는 별도로 처리 필요
              cityKR: krLocation['city']!,
              cityEN: '', // 영문 도시명은 별도로 처리 필요
              countryKR: krLocation['country']!,
              countryEN: '', // 영문 국가명은 별도로 처리 필요
              defaultYn: true,
              isServiceAvailable: isServiceAvailable,
            )
          ],
          posts: posts,
        );
        print("초기 데이터 로드 완료:");
        print("- 게시글 수: ${posts.length}");
      }
    } catch (e) {
      print("초기 데이터 로드 중 에러 발생: $e");
    }
  }

// 새 포스트를 로컬에 즉시 추가
  void addLocalPost(PostSummary post) {
    final updatedPosts = [post, ...state.posts];
    state = state.copyWith(posts: updatedPosts);
  }

  // 서버에서 새로운 포스트 가져오기
  Future<void> refreshPosts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = ref.read(userGlobalViewModel);
      if (user == null || user.address.fullNameKR.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: '사용자 위치 정보가 없습니다.',
        );
        return;
      }

      final posts = await postSummaryRepository
          .getPostSummaryList(user.address.fullNameKR);
      if (posts != null) {
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMore: posts.length >= pageSize,
        );
        print("게시글 목록 업데이트 완료:");
        print("- 새로운 게시글 수: ${posts.length}");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '게시글을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 카테고리 선택 처리
  void onCategorySelected(String category) {
    print("===== 카테고리 선택 처리 =====");
    print("선택된 카테고리: $category");

    try {
      final selectedCategory = CategoryConstants.categories.firstWhere(
        (cat) => cat['category'] == category,
        orElse: () => CategoryConstants.categories.first,
      );
      state = state.copyWith(selectedCategory: selectedCategory);
      print("카테고리 상태 업데이트 완료");
    } catch (e) {
      print("카테고리 선택 처리 중 에러 발생: $e");
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
      print("주소 목록 업데이트 완료: ${addresses.length}. ${addresses.first.cityKR}");
    } catch (e) {
      print("주소 목록 조회 중 에러 발생: $e");
    }
  }

  // 기본 주소 업데이트
  Future<void> updateDefaultAddress(String cityName) async {
    print("기본 주소 업데이트 시작: $cityName");
    try {
      final updatedAddresses = state.addresses.map((address) {
        return address.copyWith(defaultYn: address.cityKR == cityName);
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
          await postSummaryRepository.getPostSummaryList(defaultAddress.cityKR);
      if (summaries != null) {
        state = state.copyWith(posts: summaries);
        print("게시글 목록 업데이트 완료: ${summaries.length}개");
      }
    } catch (e) {
      print("게시글 목록 조회 중 에러 발생: $e");
    }
  }
}

/// Provider 정의
/// PostRepository는 직접 주입하고, UserRepository는 userGlobalViewModel을 통해 접근
/// HomeTabViewModel Provider
final homeTabViewModel =
    StateNotifierProvider<HomeTabViewModel, HomeTabState>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final addressRepository = ref.watch(addressRepositoryProvider);
  final postSummaryRepository = ref.watch(postSummaryRepositoryProvider);
  return HomeTabViewModel(
      ref, postRepository, addressRepository, postSummaryRepository);
});

// // HomeTab의 상태를 관리하는 클래스
// class HomeTabState {
//   final List<Address> addresses;
//   final List<PostSummary> posts;
//   final List<String> categories;
//   final Map<String, String>? selectedCategory;

//   const HomeTabState({
//     required this.addresses,
//     required this.posts,
//     required this.categories,
//     this.selectedCategory,
//   });

//   HomeTabState copyWith({
//     List<Address>? addresses,
//     List<PostSummary>? posts,
//     List<String>? categories,
//     Map<String, String>? selectedCategory,
//   }) {
//     return HomeTabState(
//       addresses: addresses ?? this.addresses,
//       posts: posts ?? this.posts,
//       categories: categories ?? this.categories,
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//     );
//   }
// }
//
// // HomeTab의 ViewModel 클래스
// class HomeTabViewModel extends StateNotifier<HomeTabState> {
//   // 생성자에서 ref를 받아 UserGlobalViewModel에 접근
//   HomeTabViewModel(this.ref)
//       : super(HomeTabState(
//           addresses: [],
//           posts: [],
//           categories: CategoryConstants.categories
//               .map((category) => category['category']!)
//               .toList(),
//           selectedCategory: null,
//         )) {
//     print("===== HomeTabViewModel 초기화 =====");
//     _initUserData();
//   }

//   final Ref ref;
//   final addressRepository = AddressRepository();
//   final postRepository = PostRepository();

//   // 사용자 정보 초기화
//   void _initUserData() {
//     print("===== HomeTabViewModel 사용자 정보 확인 =====");
//     try {
//       final user = ref.read(userGlobalViewModel);
//       if (user != null) {
//         print("로그인된 사용자 정보:");
//         print("- userId: ${user.userId}");
//         print("- nickname: ${user.nickname}");
//       } else {
//         print("로그인된 사용자 정보 없음");
//       }
//     } catch (e) {
//       print("사용자 정보 확인 중 에러 발생: $e");
//     }
//   }

//   // 카테고리 선택 처리
//   void onCategorySelected(String category) {
//     print("카테고리 선택: $category");
//     try {
//       final selectedCategory = CategoryConstants.categories.firstWhere(
//         (cat) => cat['category'] == category,
//         orElse: () => CategoryConstants.categories.first,
//       );
//       state = state.copyWith(selectedCategory: selectedCategory);
//       print("홈탭 카테고리 업데이트 완료: $category");
//     } catch (e) {
//       print("홈탭 카테고리 선택 에러: $e");
//     }
//   }

//   // 주소 목록 조회
//   Future<void> fetchAddresses() async {
//     print("주소 목록 가져오기 시작");
//     try {
//       final user = ref.read(userGlobalViewModel);
//       final userId = user?.userId ?? 'defaultUserId';
//       final addresses = await addressRepository.getMyAddressByEmail(userId);
//       state = state.copyWith(addresses: addresses);
//       print("주소 목록 업데이트 완료: ${addresses.length}. ${addresses.first.city}");
//     } catch (e) {
//       print("주소 목록 조회 중 에러 발생: $e");
//     }
//   }

//   // 기본 주소 업데이트
//   Future<void> updateDefaultAddress(String cityName) async {
//     print("기본 주소 업데이트 시작: $cityName");
//     try {
//       final updatedAddresses = state.addresses.map((address) {
//         return address.copyWith(defaultYn: address.city == cityName);
//       }).toList();

//       state = state.copyWith(addresses: updatedAddresses);
//       await fetchPosts();
//       print("기본 주소 업데이트 완료");
//     } catch (e) {
//       print("기본 주소 업데이트 중 에러 발생: $e");
//     }
//   }

//   // 게시글 목록 조회
//   Future<void> fetchPosts() async {
//     print("게시글 목록 가져오기 시작");
//     try {
//       if (state.addresses.isEmpty) {
//         print("주소 목록이 비어있음");
//         return;
//       }

//       final defaultAddress = state.addresses.firstWhere(
//         (e) => e.defaultYn ?? false,
//         orElse: () => state.addresses.first,
//       );

//       final summaries =
//           await postRepository.getPostSummaryList(defaultAddress.city);
//       if (summaries != null) {
//         state = state.copyWith(posts: summaries);
//         print("게시글 목록 업데이트 완료: ${summaries.length}개");
//       }
//     } catch (e) {
//       print("게시글 목록 조회 중 에러 발생: $e");
//     }
//   }
// }

// // Provider 정의 - 파일 최상위 레벨에 위치
// final homeTabViewModel =
//     StateNotifierProvider<HomeTabViewModel, HomeTabState>((ref) {
//   return HomeTabViewModel(ref);
// });
