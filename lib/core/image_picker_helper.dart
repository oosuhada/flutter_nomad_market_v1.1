import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class PickImageResult {
  final String filename;
  final String mimeType;
  final Uint8List bytes;
  PickImageResult({
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });
}

class ImagePickerHelper {
  // ImagePicker로 사진 불러와서
  // mime 패키지로 mimeType 읽은 후 함께 돌려줘야기 때문에
  
  // ImagePickerHelper.pickImage();
  static Future<PickImageResult?> pickImage() async {
    final imagePicker = ImagePicker();
    final xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name;
      // 마임타입
      // 파일 바이트 데이터 구조를 파싱해서 마임타입을 리턴해줌
      final mimeType = lookupMimeType(xFile.path, headerBytes: bytes);
      if (mimeType == null) {
        return null;
      }

      return PickImageResult(
        filename: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
    }

    return null;
  }
}
