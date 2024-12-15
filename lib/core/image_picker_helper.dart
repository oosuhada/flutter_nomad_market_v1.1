import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickImageResult {
  String title;
  String content;
  String writer;
  String imageUrl;

  PickImageResult({
    required this.title,
    required this.content,
    required this.writer,
    required this.imageUrl,
  });
}

File? imageFile;
String? imageUrl;

class ImagePickerHelper {
  static Future<PickImageResult?> pickAndUploadImage(BuildContext context,
      {bool isCamera = false}) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
    );

    if (result != null && result.isNotEmpty) {
      final File? file = await result.first.file;
      if (file != null) {
        // Firebase Storage 업로드 로직
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref();

        final imageRef = storageRef.child(
            '${DateTime.now().microsecondsSinceEpoch}_${file.path.split('/').last}');

        await imageRef.putFile(file);
        final imageUrl = await imageRef.getDownloadURL();

        return PickImageResult(
          title: 'profile image',
          content: '',
          writer: '',
          imageUrl: imageUrl,
        );
      }
    }
    return null;
  }

  static pickImageFromGallery() {}
}

class _ImagePickerHelper {
  // ImagePickerHelper.pickImage();
  static Future<PickImageResult?> pickImage() async {
    final imagePicker = ImagePicker();
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    // FirebaseStorage 객체 가지고오기
    FirebaseStorage storage = FirebaseStorage.instance;
    // 스토리지 참조 가지고 오기
    Reference storageRef = storage.ref();

    // 스토리지 참조의 child 메서드를 사용하면 파일 참조 만들어짐
    // 파라미터는 파일 이름!!

    final imageRef = storageRef
        .child('${DateTime.now().microsecondsSinceEpoch}_${xFile?.name}');
    // 참조가 만들어졌으니 파일 업로드!!
    await imageRef.putFile(File(xFile!.path));
    print('파일 업로드됨');
    // 만들어진 파일의 url 가져오기
    final imageUrl = await imageRef.getDownloadURL();
    print(imageUrl);

    return PickImageResult(
      title: 'profile image',
      content: '',
      writer: '',
      imageUrl: imageUrl,
    );
  }
}

// import 'dart:core';
// import 'package:flutter/material.dart';
// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// class PickImageResult {
//   String title;
//   String content;
//   String writer;
//   String imageUrl;

//   PickImageResult({
//     required this.title,
//     required this.content,
//     required this.writer,
//     required this.imageUrl,
//   });
// }

// class ImagePickerHelper {
//   // ImagePickerHelper.pickImage();
//   static Future<PickImageResult?> pickImage(BuildContext context) async {
//     final List<AssetEntity>? assets = await AssetPicker.pickAssets(
//       context,
//       pickerConfig: AssetPickerConfig(
//         maxAssets: 1,
//         requestType: RequestType.image,
//       ),
//     );

//     if (assets == null || assets.isEmpty) {
//       return null;
//     }

//     final File? file = await assets.first.file;
//     if (file == null) {
//       return null;
//     }

//     // FirebaseStorage 객체 가지고오기
//     FirebaseStorage storage = FirebaseStorage.instance;
//     // 스토리지 참조 가지고 오기
//     Reference storageRef = storage.ref();

//     // 스토리지 참조의 child 메서드를 사용하면 파일 참조 만들어짐
//     // 파라미터는 파일 이름!!

//     final imageRef = storageRef.child(
//         '${DateTime.now().microsecondsSinceEpoch}_${file.path.split('/').last}');
//     // 참조가 만들어졌으니 파일 업로드!!
//     await imageRef.putFile(file);
//     print('파일 업로드됨');
//     // 만들어진 파일의 url 가져오기
//     final imageUrl = await imageRef.getDownloadURL();
//     print(imageUrl);

//     return PickImageResult(
//       title: 'profile image',
//       content: '',
//       writer: '',
//       imageUrl: imageUrl,
//     );
//   }
// }
