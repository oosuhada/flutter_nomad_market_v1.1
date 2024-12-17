import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/model/user.dart';
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
  final bool isInitialized; // 새로 추가된 필드

  const HomeTabState({
    required this.addresses,
    required this.posts,
    required this.categories,
    this.selectedCategory,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.isInitialized = false, // 기본값을 false로 설정
  });

  HomeTabState copyWith({
    List<Address>? addresses,
    List<PostSummary>? posts,
    List<String>? categories,
    Map<String, String>? selectedCategory,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool? isInitialized, // copyWith 메서드에도 추가
  }) {
    return HomeTabState(
      addresses: addresses ?? this.addresses,
      posts: posts ?? this.posts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized, // copyWith에 포함
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
    print("- 초기 addresses 길이: ${state.addresses.length}");
    print("- 초기 posts 길이: ${state.posts.length}");
    print("- 초기 categories 길이: ${state.categories.length}");
    initializeData();
  }

  Future<void> initializeData() async {
    print("===== HomeTabViewModel 데이터 초기화 시작 =====");
    try {
      final user = ref.read(userGlobalViewModel);
      if (user != null) {
        print("로그인된 사용자 확인:");
        print("- userId: ${user.userId}");
        print("- nickname: ${user.nickname}");
        print("- address: ${user.address.fullNameKR}");

        if (user.address.fullNameKR.isNotEmpty) {
          final defaultAddress = user.address.fullNameKR;

          // 주소 정보 파싱 및 처리
          final addressParts = defaultAddress.split(',');
          final cityWithState = addressParts[0].trim();
          final country = addressParts.length > 1 ? addressParts[1].trim() : '';

          // Address.processLocationInfo를 사용하여 주소 정보 정제
          final krLocation = Address.processLocationInfo(cityWithState, country,
              isKorean: true);

          // 서비스 가능 여부 확인
          final isServiceAvailable = Address.checkServiceAvailability(
              krLocation['city']!, krLocation['country']!);

          // 주소 정보 설정
          state = state.copyWith(
            addresses: [
              Address(
                id: '',
                fullNameKR: defaultAddress,
                fullNameEN: '',
                cityKR: krLocation['city']!,
                cityEN: '',
                countryKR: krLocation['country']!,
                countryEN: '',
                defaultYn: true,
                isServiceAvailable: isServiceAvailable,
              )
            ],
          );

          // 게시글 로드
          final posts = await postSummaryRepository.getAllProducts();
          state = state.copyWith(
            posts: posts,
            isLoading: false,
            hasMore: posts.length >= pageSize,
          );
          print("초기 데이터 로드 완료:");
          print("- 게시글 수: ${posts.length}");
          print("- 주소 정보: ${state.addresses.first.fullNameKR}");
        }
      } else {
        print("로그인된 사용자 정보 없음 - 초기 데이터 로드 건너뜀");
      }
    } catch (e, stack) {
      print("데이터 초기화 중 에러 발생:");
      print("- 에러: $e");
      print("- 스택트레이스: $stack");
      state = state.copyWith(
        error: '데이터 초기화 중 오류가 발생했습니다.',
        isLoading: false,
      );
    }
  }

  Future<void> setInitialAddress(User user) async {
    if (user.address.fullNameKR.isNotEmpty) {
      final defaultAddress = user.address.fullNameKR;

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

      // 주소 정보 설정
      state = state.copyWith(
        addresses: [
          Address(
            id: '',
            fullNameKR: defaultAddress,
            fullNameEN: '',
            cityKR: krLocation['city']!,
            cityEN: '',
            countryKR: krLocation['country']!,
            countryEN: '',
            defaultYn: true,
            isServiceAvailable: isServiceAvailable,
          )
        ],
      );

      print("초기 주소 설정 완료:");
      print("- 주소 정보: ${state.addresses.first.fullNameKR}");
    }
  }

  Future<void> loadAllProducts() async {
    print('===== loadAllProducts 시작 =====');
    state = state.copyWith(isLoading: true);

    try {
      final postSummaries = await postSummaryRepository.getAllProducts();
      print('가져온 상품 수: ${postSummaries.length}');

      // 데이터 검증 로그 추가
      for (var post in postSummaries) {
        print('상품 데이터 확인:');
        print('- ID: ${post.id}');
        print('- 제목: ${post.originalTitle}');
        print('- 가격: ${post.price} ${post.currency}');
        print('- 주소: ${post.address.fullNameKR}');
      }

      if (postSummaries.isNotEmpty) {
        // 상태 업데이트 전 데이터 검증
        print('상태 업데이트 시작 - 기존 posts 길이: ${state.posts.length}');

        state = state.copyWith(
          posts: postSummaries,
          isLoading: false,
          hasMore: postSummaries.length >= pageSize,
        );

        print('상태 업데이트 완료 - 새로운 posts 길이: ${state.posts.length}');
        print('첫 번째 게시물 제목: ${state.posts.first.originalTitle}');
      } else {
        print('가져온 상품이 없음');
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
      }
    } catch (e, stack) {
      print('loadAllProducts 에러 발생');
      print('에러: $e');
      print('스택트레이스: $stack');
      state = state.copyWith(
        error: '상품 목록을 불러오는데 실패했습니다: $e',
        isLoading: false,
      );
    }
  }

// 새 포스트를 로컬에 즉시 추가
  void addLocalPost(PostSummary post) {
    final updatedPosts = [post, ...state.posts];
    state = state.copyWith(posts: updatedPosts);
  }

// 탭 전환 시 데이터 리프레시를 위한 메서드
  Future<void> onTabSelected() async {
    print("===== 홈 탭 선택됨 =====");
    state = state.copyWith(isLoading: true);
    await loadAllProducts();
    state = state.copyWith(isLoading: false, isInitialized: true);
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

      final posts = await postSummaryRepository.getAllProducts();
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

  Future<void> loadMorePosts() async {
    // 이미 로딩 중이거나 더 불러올 데이터가 없으면 종료
    if (state.isLoading || !state.hasMore) {
      print(
          "추가 데이터 로드 중단: isLoading=${state.isLoading}, hasMore=${state.hasMore}");
      return;
    }

    print("===== 추가 데이터 로드 시작 =====");
    state = state.copyWith(isLoading: true);

    try {
      final user = ref.read(userGlobalViewModel);
      if (user == null || user.address.fullNameKR.isEmpty) {
        print("사용자 주소 정보 없음");
        state = state.copyWith(isLoading: false, error: '사용자 주소 정보가 없습니다.');
        return;
      }

      // 현재 게시글 수
      final currentPostCount = state.posts.length;

      // 추가 데이터 요청
      final newPosts = await postSummaryRepository.getPostSummaryList(
        addressId: user.address.fullNameKR,
        limit: pageSize,
        // 현재 게시글의 마지막 항목을 기준으로 가져오기 (Pagination)
        // 'updatedAt' 필드가 페이지네이션의 기준이라고 가정
      );

      if (newPosts.isNotEmpty) {
        print("추가 데이터 로드 완료: ${newPosts.length}개");
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          hasMore: newPosts.length >= pageSize,
          isLoading: false,
        );
      } else {
        print("더 이상 불러올 데이터 없음");
        state = state.copyWith(hasMore: false, isLoading: false);
      }
    } catch (e, stackTrace) {
      print("추가 데이터 로드 중 에러 발생: $e");
      print("스택트레이스: $stackTrace");
      state = state.copyWith(
        isLoading: false,
        error: '추가 데이터를 불러오는 중 오류가 발생했습니다.',
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
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('posts').get();
      print("Firebase에서 가져온 원본 데이터:");
      snapshot.docs.forEach((doc) => print(doc.data()));

      final posts =
          snapshot.docs.map((doc) => PostSummary.fromJson(doc.data())).toList();
      state = state.copyWith(posts: posts);
    } catch (e) {
      print("데이터 가져오기 오류: $e");
    }
  }
}

/// Provider 정의
/// PostRepository는 직접 주입하고, UserRepository는 userGlobalViewModel을 통해 접근
/// HomeTabViewModel Provider
final homeTabViewModel =
    StateNotifierProvider.autoDispose<HomeTabViewModel, HomeTabState>((ref) {
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
