import 'dart:core';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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

class ImagePickerHelper {
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
