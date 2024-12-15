import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_market_app/ui/widgets/join_text_form_field.dart';
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
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? imageFile;
  String? imageUrl;

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  void onImageUpload() async {
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
  // final validateResult = await viewModel.validateName(
  //   username: idController.text,
  //   nickname: nicknameController.text,
  // );

  // if (validateResult != null) {
  //   SnackbarUtil.showSnackBar(context, validateResult);
  //   return;
  // }
  // void onJoin() async {
  //   if (formKey.currentState?.validate() ?? false) {
  //     final viewModel = ref.watch(joinViewModel);

  //     final result = await viewModel.join(
  //       nickname: nicknameController.text,
  //       email: emailController.text,
  //       password: pwController.text,
  //       addressFullName: widget.address,
  //       profileImageUrl: imageUrl ?? '',
  //     );
  //     if (result == true) {
  //       // WelcomePage 이동
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return WelcomePage();
  //           },
  //         ),
  //         (route) {
  //           return false;
  //         },
  //       );
  //     } else {
  //       SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
  //     }
  //   }
  //   print('onJoin');
  // }
  void onJoin() async {
    if (formKey.currentState?.validate() ?? false) {
      final email = emailController.text.trim();
      final password = pwController.text.trim();
      final nickname = nicknameController.text.trim();

      if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
        SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
        return;
      }

      final viewModel = ref.read(joinViewModel);
      final result = await viewModel.join(
        nickname: nickname,
        email: email,
        password: password,
        addressFullName: widget.address,
        profileImageUrl: imageUrl ?? '',
      );

      if (result == true) {
        // WelcomePage 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
          (route) => false,
        );
      } else {
        SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
      }
    } else {
      SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
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
              GestureDetector(
                onTap: onImageUpload,
                child: Align(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 60,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '프로필 사진',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              JoinTextFormField(controller: emailController),
              SizedBox(height: 20),
              PwTextFormField(controller: pwController),
              SizedBox(height: 20),
              NicknameTextFormField(controller: nicknameController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onJoin,
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
