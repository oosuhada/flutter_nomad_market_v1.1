import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/firebase_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FileRepository provider 정의
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository();
});

class FileRepository extends FirebaseRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// 파일을 Firebase Storage에 업로드하는 메서드
  /// - bytes: 파일 데이터
  /// - filename: 저장될 파일명
  /// - mimeType: 파일 타입 (예: image/jpeg)
  Future<FileModel?> upload({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    print("===== 파일 업로드 시작 =====");
    print("파일명: $filename");
    print("파일 타입: $mimeType");
    print("파일 크기: ${bytes.length} bytes");

    try {
      // 스토리지 참조 생성 - files 폴더 아래에 파일 저장
      final actualFileName = filename.split('/').last;
      final ref = storage.ref().child('files/$actualFileName');
      print("저장 경로: files/$actualFileName");

      // 메타데이터와 함께 파일 업로드 시작
      print("파일 업로드 시작...");
      final uploadTask = ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: mimeType),
      );

      // 업로드 진행 상태 모니터링
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("업로드 진행률: ${progress.toStringAsFixed(1)}%");
      });

      // 업로드 완료 대기
      print("업로드 완료 대기 중...");
      final snapshot = await uploadTask;

      // 다운로드 URL 획득
      print("다운로드 URL 요청 중...");
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("다운로드 URL 획득: $downloadUrl");

      // FileModel 생성 및 반환
      final fileModel = FileModel(
        id: ProfileImageUrlHelper.createStoragePath(filename),
        url: downloadUrl,
        originName: filename,
        contentType: mimeType,
        createdAt: DateTime.now().toIso8601String(),
      );

      print("===== 파일 업로드 완료 =====");
      print("파일 ID: ${fileModel.id}");
      return fileModel;
    } catch (e, stackTrace) {
      print("===== 파일 업로드 실패 =====");
      print("에러 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      print("스택 트레이스: $stackTrace");
      return null;
    }
  }
}

// FileViewModel 추가
class FileViewModel extends StateNotifier<AsyncValue<FileModel?>> {
  final FileRepository fileRepository;

  FileViewModel({required this.fileRepository})
      : super(const AsyncValue.data(null));

  Future<void> uploadFile({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      state = const AsyncValue.loading();

      final fileModel = await fileRepository.upload(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );

      state = AsyncValue.data(fileModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

// FileViewModel provider 정의
final fileViewModelProvider =
    StateNotifierProvider<FileViewModel, AsyncValue<FileModel?>>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  return FileViewModel(fileRepository: repository);
});



// // UI에서 사용 예시
// class MyWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 상태 관찰
//     final fileState = ref.watch(fileViewModelProvider);
    
//     return fileState.when(
//       data: (fileModel) {
//         if (fileModel != null) {
//           return Text('File uploaded: ${fileModel.url}');
//         }
//         return Text('No file uploaded');
//       },
//       loading: () => CircularProgressIndicator(),
//       error: (error, stack) => Text('Error: $error'),
//     );
//   }

//   // 파일 업로드 메서드
//   Future<void> uploadFile(WidgetRef ref, List<int> bytes, String filename) async {
//     final viewModel = ref.read(fileViewModelProvider.notifier);
//     await viewModel.uploadFile(
//       bytes: bytes,
//       filename: filename,
//       mimeType: 'image/jpeg',
//     );
//   }
// }