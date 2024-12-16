import 'package:dio/dio.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 게시글 작성 상태를 관리하는 클래스
class PostWriteState {
  final List<FileModel> imageFiles; // 업로드된 이미지 파일들
  final List<String> categories; // 카테고리 목록
  final Map<String, String>? selectedCategory; // 선택된 카테고리 정보
  final String? userId; // 사용자 ID
  final String? userNickname; // 사용자 닉네임
  final String? userProfileImageUrl; // 사용자 프로필 이미지 URL
  final String? userHomeAddress; // 사용자 주소

  PostWriteState({
    required this.imageFiles,
    required this.categories,
    this.selectedCategory,
    this.userId,
    this.userNickname,
    this.userProfileImageUrl,
    this.userHomeAddress,
  });

  // 상태 복사 메서드
  PostWriteState copyWith({
    List<FileModel>? imageFiles,
    List<String>? categories,
    Map<String, String>? selectedCategory,
    String? userId,
    String? userNickname,
    String? userProfileImageUrl,
    String? userHomeAddress,
  }) {
    return PostWriteState(
      imageFiles: imageFiles ?? this.imageFiles,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      userHomeAddress: userHomeAddress ?? this.userHomeAddress,
    );
  }
}

// 게시글 작성 뷰모델 클래스
class PostWriteViewModel
    extends AutoDisposeFamilyNotifier<PostWriteState, Post?> {
  @override
  PostWriteState build(Post? arg) {
    // 초기 상태 설정
    return PostWriteState(
      imageFiles: arg?.images
              .map((e) => FileModel(
                    id: e,
                    url: e,
                    originName: '',
                    contentType: '',
                    createdAt: DateTime.now().toIso8601String(),
                  ))
              .toList() ??
          [],
      categories: CategoryConstants.categories
          .map((category) => category['category']!)
          .toList(),
      selectedCategory: arg?.category != null
          ? CategoryConstants.categories.firstWhere(
              (cat) => cat['id'] == arg!.category,
              orElse: () => CategoryConstants.categories.first)
          : null,
      userId: arg?.userId,
      userNickname: arg?.userNickname,
      userProfileImageUrl: arg?.userProfileImageUrl,
      userHomeAddress: arg?.userHomeAddress,
    );
  }

  final fileRepository = FileRepository(Dio());
  final postRepository = PostRepository();

  // 카테고리 선택 처리
  void onCategorySelected(String category) {
    print("===== 카테고리 선택 시도 =====");
    print("선택된 카테고리: $category");

    try {
      final selectedCategory = CategoryConstants.categories.firstWhere(
        (cat) => cat['category'] == category,
        orElse: () => CategoryConstants.categories.first, // 기본값 제공
      );
      print("찾은 카테고리 정보: $selectedCategory");

      state = state.copyWith(selectedCategory: selectedCategory);
      print("상태 업데이트 완료");
    } catch (e, stackTrace) {
      print("카테고리 선택 중 에러:");
      print(e);
      print(stackTrace);
    }
  }

  // 이미지 업로드 처리
  Future<void> uploadImage({
    required String filename,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final result = await fileRepository.upload(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
    if (result != null) {
      state = state.copyWith(
        imageFiles: [...state.imageFiles, result],
      );
    }
  }

  // 게시글 업로드 처리
  Future<Post?> upload({
    required String originalTitle,
    required String translatedTitle,
    required Price price,
    required String originalDescription,
    required String translatedDescription,
    required String location,
    required String userNickname,
    required String userProfileImageUrl,
    required String userHomeAddress,
  }) async {
    print("===== PostWriteViewModel upload 시작 =====");
    print("이미지 파일 수: ${state.imageFiles.length}");
    print("선택된 카테고리: ${state.selectedCategory}");
    print("사용자 ID: ${state.userId}");

    // 필수 데이터 검증
    if (state.imageFiles.isEmpty ||
        state.selectedCategory == null ||
        state.userId == null) {
      print("필수 데이터 누락:");
      print("- 이미지 파일 존재: ${state.imageFiles.isNotEmpty}");
      print("- 카테고리 선택됨: ${state.selectedCategory != null}");
      print("- 사용자 ID 존재: ${state.userId != null}");
      return null;
    }

    try {
      if (arg != null) {
        print("기존 게시글 수정 시도");
        // 기존 게시글 수정 로직...
      } else {
        print("새 게시글 생성 시도");
        print("전달되는 데이터:");
        print("- 제목: $originalTitle");
        print("- 가격: ${price.amount} ${price.currency}");
        print("- 이미지 URLs: ${state.imageFiles.map((e) => e.url).toList()}");
        print("- 카테고리: ${state.selectedCategory!['id']}");

        final result = await postRepository.create(
          postId: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: state.userId!,
          originalTitle: originalTitle,
          translatedTitle: translatedTitle,
          images: state.imageFiles.map((e) => e.url).toList(),
          category: state.selectedCategory!['id']!,
          price: price,
          status: PostStatus.selling,
          negotiable: true,
          originalDescription: originalDescription,
          translatedDescription: translatedDescription,
          location: location,
          userNickname: userNickname,
          userProfileImageUrl: userProfileImageUrl,
          userHomeAddress: userHomeAddress,
        );

        print("게시글 생성 결과: ${result != null ? '성공' : '실패'}");
        if (result != null) {
          print("생성된 게시글 ID: ${result.postId}");
        }
        return result;
      }
    } catch (e, stackTrace) {
      print("===== 게시글 업로드 중 에러 발생 =====");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      return null;
    }
    return null;
  }

  // 사용자 정보 설정
  void setUserInfo({
    required String userId,
    required String nickname,
    required String profileImageUrl,
    required String homeAddress,
  }) {
    state = state.copyWith(
      userId: userId,
      userNickname: nickname,
      userProfileImageUrl: profileImageUrl,
      userHomeAddress: homeAddress,
    );
  }
}

// 뷰모델 프로바이더 정의
final postWriteViewModel = NotifierProvider.autoDispose
    .family<PostWriteViewModel, PostWriteState, Post?>(() {
  return PostWriteViewModel();
});


// 주요 변경사항:
// 1. `ProductCategoryRepository` 제거 및 `CategoryConstants` 직접 사용
// 2. 카테고리 관리 로직 수정
// 3. 상태 클래스의 categories 타입을 `List<String>`으로 변경
// 4. 모든 주요 메서드와 클래스에 한글 주석 추가
// 5. 상태 업데이트 로직 개선

// 이제 이 뷰모델은 서버 통신 없이 로컬에서 카테고리를 관리하며, 더 명확한 한글 주석으로 코드의 이해도를 높였습니다.