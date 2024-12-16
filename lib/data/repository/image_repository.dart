// image_repository.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/image_model.dart';
import 'package:path/path.dart' as path;

class ImageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ImageModel?> uploadImage(File file, String folder) async {
    try {
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref().child('$folder/$filename');

      // 원본 이미지 업로드
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // 썸네일 생성 및 업로드 (옵션)
      String? thumbnailUrl;
      // TODO: 썸네일 생성 로직 구현

      return ImageModel(
        url: url,
        thumbnail: thumbnailUrl,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('이미지 삭제 오류: $e');
      return false;
    }
  }

  Future<List<ImageModel>> uploadMultipleImages(
      List<File> files, String folder) async {
    final List<ImageModel> uploadedImages = [];

    for (final file in files) {
      final image = await uploadImage(file, folder);
      if (image != null) {
        uploadedImages.add(image);
      }
    }

    return uploadedImages;
  }
}
