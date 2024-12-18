import 'dart:io';

import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';
import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/post_repository.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 게시글 작성 상태를 관리하는 클래스
class PostWriteState {
  final List<FileModel> uploadedImageFiles; // 서버로 업로드된 이미지
  final List<File> localImageFiles; // 로컬에서 선택된 이미지
  final List<String> categories; // 카테고리 목록
  final Map<String, String>? selectedCategory; // 선택된 카테고리 정보
  final String? userId; // 사용자 ID
  final String? userNickname; // 사용자 닉네임
  final String? userProfileImageUrl; // 사용자 프로필 이미지 URL
  final Address? userHomeAddress; // 사용자 주소
  final PostType tradeType; // 거래 유형 추가 (판매/구매)

  PostWriteState({
    required this.uploadedImageFiles,
    required this.localImageFiles,
    required this.categories,
    this.selectedCategory,
    this.userId,
    this.userNickname,
    this.userProfileImageUrl,
    this.userHomeAddress,
    this.tradeType = PostType.selling, // 기본값으로 판매 설정
  });

  // 상태 복사 메서드
  PostWriteState copyWith({
    List<FileModel>? uploadedImageFiles,
    List<File>? localImageFiles,
    List<String>? categories,
    Map<String, String>? selectedCategory,
    String? userId,
    String? userNickname,
    String? userProfileImageUrl,
    Address? userHomeAddress,
    required PostType tradeType, // 거래 유형 추가 (판매/구매)
  }) {
    return PostWriteState(
      uploadedImageFiles: uploadedImageFiles ?? this.uploadedImageFiles,
      localImageFiles: localImageFiles ?? this.localImageFiles,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      userHomeAddress: userHomeAddress ?? this.userHomeAddress,
      tradeType: tradeType,
    );
  }
}

// 게시글 작성 뷰모델 클래스
class PostWriteViewModel
    extends AutoDisposeFamilyNotifier<PostWriteState, Post?> {
  @override
  PostWriteState build(Post? arg) {
    // 사용자 상태 스트림 구독
    final userState = ref.watch(userGlobalViewModel);
    final user = userState?.user;
    print("===== PostWriteViewModel 초기화 =====");

    // userGlobalViewModel에서 현재 상태를 읽어옴

    print("현재 사용자 정보 읽기 시도:");
    print("- userState: ${userState?.toString()}");

    if (userState == null) {
      print("경고: 사용자 상태가 null입니다");
    }

    return PostWriteState(
      uploadedImageFiles: arg?.images
              .map((e) => FileModel(
                    id: e.id,
                    url: e.url,
                    originName: '',
                    contentType: '',
                    createdAt: DateTime.now().toIso8601String(),
                  ))
              .toList() ??
          [],
      localImageFiles: [],
      categories: CategoryConstants.categories
          .map((category) => category['category']!)
          .toList(),
      selectedCategory: arg?.category != null
          ? CategoryConstants.categories.firstWhere(
              (cat) => cat['id'] == arg!.category,
              orElse: () => CategoryConstants.categories.first)
          : null,
      userId: user?.userId,
      userNickname: user?.nickname,
      userProfileImageUrl: user?.profileImageUrl ?? 'assets/defaultprofile.jpg',
      userHomeAddress: user?.address,
    );
  }

  final fileRepository = FileRepository();
  final postRepository = PostRepository();

  // 로컬 이미지 추가
  void addLocalImages(List<File> images) {
    print("===== 로컬 이미지 추가 =====");
    print("추가할 이미지 수: ${images.length}");

    state = state.copyWith(
      localImageFiles: [...state.localImageFiles, ...images],
      tradeType: PostType.selling,
    );
    print("현재 로컬 이미지 수: ${state.localImageFiles.length}");
  }

  // 서버 이미지 업로드
  Future<bool> uploadLocalImages() async {
    print("===== 서버 이미지 업로드 시작 =====");
    print("업로드할 로컬 이미지 수: ${state.localImageFiles.length}");

    try {
      List<FileModel> uploadedFiles = [];

      for (var file in state.localImageFiles) {
        print("이미지 업로드 시도: ${file.path}");
        final bytes = await file.readAsBytes();

        final result = await fileRepository.upload(
          bytes: bytes,
          filename: file.path.split('/').last,
          mimeType: 'image/jpeg',
        );

        if (result != null) {
          print("이미지 업로드 성공: ${result.url}");
          uploadedFiles.add(result);
        }
      }

      if (uploadedFiles.isNotEmpty) {
        state = state.copyWith(
          uploadedImageFiles: [...state.uploadedImageFiles, ...uploadedFiles],
          localImageFiles: [], tradeType: PostType.selling, // 업로드 완료된 로컬 이미지 제거
        );
        print("모든 이미지 업로드 완료");
        print("업로드된 이미지 수: ${state.uploadedImageFiles.length}");
        return true;
      }
      return false;
    } catch (e) {
      print("이미지 업로드 중 에러: $e");
      return false;
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
    required Address userHomeAddress,
  }) async {
    print("===== PostWriteViewModel upload 시작 =====");
    print("업로드된 이미지 수: ${state.uploadedImageFiles.length}");
    print("upload - 로컬 이미지 수: ${state.localImageFiles.length}");
    print("선택된 카테고리: ${state.selectedCategory}");
    print("사용자 ID: ${state.userId}");

    // 먼저 로컬 이미지 업로드
    if (state.localImageFiles.isNotEmpty) {
      print("로컬 이미지 업로드 시작");
      final uploadSuccess = await uploadLocalImages();
      if (!uploadSuccess) {
        print("이미지 업로드 실패");
        return null;
      }
    }

    // 필수 데이터 검증
    if (state.uploadedImageFiles.isEmpty ||
        state.selectedCategory == null ||
        state.userId == null) {
      print("필수 데이터 누락:");
      print("- 이미지 파일 존재: ${state.uploadedImageFiles.isNotEmpty}");
      print("- 카테고리 선택됨: ${state.selectedCategory != null}");
      print("- 사용자 ID 존재: ${state.userId != null}");
      return null;
    }

    try {
      final images = state.uploadedImageFiles;

      final result = await postRepository.createPost(
        userId: state.userId!,
        originalTitle: originalTitle,
        translatedTitle: translatedTitle,
        images: images,
        category: state.selectedCategory!['id']!,
        price: price,
        type: state.tradeType,
        status: PostStatus.active,
        negotiable: true, // 수정 필요 시 인자로 받을 수 있음
        originalDescription: originalDescription,
        translatedDescription: translatedDescription,
        address: userHomeAddress,
        userNickname: userNickname,
        userProfileImageUrl: userProfileImageUrl,
        userAddress: userHomeAddress,
        language: "ko", // 언어 정보는 고정 또는 사용자 설정 기반으로 처리
      );

      print("게시글 생성 결과: ${result != null ? '성공' : '실패'}");
      return result;
    } catch (e, stackTrace) {
      print("===== 게시글 업로드 중 에러 발생 =====");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      return null;
    }
  }

  void onTradeTypeSelected(PostType type) {
    state = state.copyWith(tradeType: type);
    print("거래 유형 변경: $type");
  }

  void onCategorySelected(String category) {
    final selectedCategory = CategoryConstants.categories.firstWhere(
      (c) => c['category'] == category,
      orElse: () => {'id': '', 'category': ''},
    );
    state = state.copyWith(
        selectedCategory: selectedCategory, tradeType: PostType.selling);
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