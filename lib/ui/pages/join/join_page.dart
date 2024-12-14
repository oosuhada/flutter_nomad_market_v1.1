import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_market_app/ui/widgets/id_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/nickname_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class JoinPage extends ConsumerStatefulWidget {
  JoinPage(this.address);

  final String address;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? imageFile;
  String? imageUrl;
  void onGoogleSignIn(WidgetRef ref) {
    // Google 로그인 로직 구현
  }

  void onFacebookSignIn(WidgetRef ref) {
    // Facebook 로그인 로직 구현
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> onImageUpload() async {
    print('onImageUpload');
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery, // 갤러리에서 선택
      imageQuality: 50, // 이미지 품질 (0~100)
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path); // 선택한 이미지 파일 저장
        imageUrl = pickedImage.path; // 선택한 이미지 파일 경로 저장
      });
    }
  }

  void onJoin() async {
    if (formKey.currentState?.validate() ?? false) {
      final viewModel = ref.watch(joinViewModel);

      // final validateResult = await viewModel.validateName(
      //   username: idController.text,
      //   nickname: nicknameController.text,
      // );

      // if (validateResult != null) {
      //   SnackbarUtil.showSnackBar(context, validateResult);
      //   return;
      // }

      final result = await viewModel.join(
        nickname: nicknameController.text,
        email: idController.text,
        password: pwController.text,
        addressFullName: widget.address,
        profileImageUrl: imageUrl ?? '',
      );
      if (result == true) {
        // WelcomePage 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WelcomePage();
            },
          ),
          (route) {
            return false;
          },
        );
      } else {
        SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
      }
    }
    print('onJoin');
  }

  @override
  Widget build(BuildContext context) {
    print(widget.address);
    // final postModel = ref.read(profileImageViewModel);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              //
              Text(
                '안녕하세요!\n이메일과 비밀번호로 가입해주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: onImageUpload,
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(65),
                                child: Image.file(
                                  imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: imageFile != null
                                ? Colors.purple.shade900
                                : Colors.grey.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              IdTextFormField(controller: idController),
              SizedBox(height: 20),
              PwTextFormField(controller: pwController),
              SizedBox(height: 20),
              NicknameTextFormField(controller: nicknameController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onJoin,
                child: Text('회원가입'),
              ),
              SizedBox(height: 20),
              // 소셜 로그인 구분선
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '또는',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: 16),
              // 소셜 로그인 버튼
              Consumer(
                builder: (context, ref, child) {
                  return Column(
                    children: [
                      // 구글 로그인 버튼
                      GestureDetector(
                        onTap: () => onGoogleSignIn(ref),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[900]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15),
                                Icon(
                                  Icons.account_box,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '구글 아이디로 계속하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 페이스북 로그인 버튼
                      GestureDetector(
                        onTap: () => onFacebookSignIn(ref),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[900]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15),
                                Icon(
                                  Icons.facebook,
                                  color: const Color.fromARGB(255, 33, 47, 125),
                                  size: 40,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '페이스북 아이디로 계속하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
