import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/data/model/user.dart';
import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/login/login_view_model.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_market_app/ui/widgets/join_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/nickname_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_market_app/ui/pages/login/login_page.dart';
import 'package:flutter_market_app/ui/pages/social_id.dart';

class JoinPage extends ConsumerStatefulWidget {
  final String language;
  final String address;
  final String currency;

  const JoinPage({
    Key? key,
    required this.language,
    required this.address,
    required this.currency,
  }) : super(key: key);

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  final emailController = TextEditingController();
  late final String selectedLanguage;
  late final String selectedAddress;
  late final String selectedCurrency;
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final fileRepository = FileRepository();
  File? imageFile;
  String? imageUrl;
  String? tempImagePath;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.language;
    selectedAddress = widget.address;
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    nicknameController.dispose();
    imageFile?.delete();
    imageFile = null;
    super.dispose();
  }

  Future<void> onImageUpload() async {
    print('onImageUpload 함수 시작');
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        print('CupertinoActionSheet 빌더 호출');
        final theme = Theme.of(context);
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                print('갤러리 선택 버튼 클릭');
                Navigator.of(context).pop();
                print('갤러리에서 이미지 선택 시작');
                await pickAndShowImage(ImageSource.gallery);
                print('갤러리에서 이미지 선택 및 표시 완료');
              },
              child: Text('갤러리에서 선택',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                print('카메라 촬영 버튼 클릭');
                Navigator.of(context).pop();
                print('카메라로 이미지 촬영 시작');
                await pickAndShowImage(ImageSource.camera);
                print('카메라로 이미지 촬영 및 표시 완료');
              },
              child: Text('카메라로 촬영',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              print('취소 버튼 클릭');
              Navigator.of(context).pop();
            },
            child: Text('취소',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
          ),
        );
      },
    );
    print('onImageUpload 함수 종료');
  }

  Future<void> pickAndShowImage(ImageSource source) async {
    print('pickAndShowImage 함수 시작');
    final XFile? pickedFile = await _pickImage(source);
    if (pickedFile != null) {
      await showLocalImage(pickedFile);
    }
    print('pickAndShowImage 함수 종료');
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    print('이미지 선택 시작');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    print('이미지 선택 완료: ${image?.path}');
    return image;
  }

  Future<void> showLocalImage(XFile file) async {
    print('로컬 이미지 표시 시작');
    setState(() {
      imageFile = File(file.path);
      // 임시 로컬 경로 저장
      tempImagePath = file.path;
    });
    print('로컬 이미지 표시 완료');
  }

  // 계정 생성 메서드 추가
  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final userRepository = UserRepository();
      // Firebase Auth의 계정 생성 시도
      final credential = await userRepository.createAuthAccount(
        email: email,
        password: password,
      );
      return credential != null;
    } catch (e) {
      print('계정 생성 실패: $e');
      return false;
    }
  }

// onJoin 메서드 수정
  void onJoin() async {
    if (formKey.currentState?.validate() ?? false) {
      final email = emailController.text.trim();
      final password = pwController.text.trim();
      final nickname = nicknameController.text.trim();

      if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
        SnackbarUtil.showSnackBar(context, '필수 정보를 모두 입력해주세요');
        return;
      }

      // 회원가입 viewModel 준비
      final viewModel = ref.read(joinViewModel.notifier);
      String? uploadedImageUrl;

      try {
        // 먼저 계정 생성 시도
        final accountCreated = await viewModel.createAccount(
          email: email,
          password: password,
        );

        if (!accountCreated) {
          SnackbarUtil.showSnackBar(context, '계정 생성에 실패했습니다');
          return;
        }

        // 계정 생성 성공 후 이미지 업로드 진행
        if (tempImagePath != null) {
          final file = XFile(tempImagePath!);
          final bytes = await file.readAsBytes();
          final fileName = file.path.split('/').last;
          final fileModel = await FileRepository().upload(
            bytes: bytes,
            filename: fileName,
            mimeType: 'image/jpeg',
          );
          uploadedImageUrl = fileModel?.url;
        }

        // 최종 회원가입 정보 저장
        final result = await viewModel.join(
          nickname: nickname,
          email: email,
          password: password,
          addressFullName: selectedAddress,
          profileImageUrl: uploadedImageUrl ?? '',
          language: selectedLanguage.split(' ')[0].toLowerCase(),
          currency: selectedCurrency.split(' ')[0],
        );

        if (result == true) {
          // null-safe한 비교로 변경
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원가입이 성공적으로 완료되었습니다'),
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(Duration(seconds: 2));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        } else {
          SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
        }
      } catch (e) {
        print('회원가입 오류: $e');
        SnackbarUtil.showSnackBar(context, '회원가입 처리 중 오류가 발생했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                '안녕하세요!\n이메일과 비밀번호로 가입해주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: onImageUpload,
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
                                  size: 90,
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 110,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade900,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 0),
                      ),
                      child: Icon(
                        CupertinoIcons.camera,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              Consumer(
                builder: (context, ref, child) {
                  final authService = ref.read(authServiceProvider);
                  return GestureDetector(
                    onTap: () async {
                      final success = await authService.onGoogleSignIn(context);
                      if (success) {
                        // 로그인 성공 시 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Google 계정으로 가입되었습니다'),
                            duration: Duration(seconds: 3),
                          ),
                        );

                        await Future.delayed(Duration(seconds: 2));

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: () => authService.onGoogleSignIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.white,
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[100]
                                  : Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google_logo.png', height: 24),
                            SizedBox(width: 8),
                            Text(
                              '구글 아이디로 계속하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class UserDataFormatter {
  static String formatLanguage(String language) {
    // "한국어" -> "ko"
    // "English" -> "en" 등으로 변환
    final languageMap = {
      "한국어": "ko",
      "English": "en",
      // 필요한 언어 매핑 추가
    };
    return languageMap[language] ?? "ko";
  }

  static String formatCurrency(String currency) {
    // "KRW (₩)" -> "KRW"
    // "USD ($)" -> "USD" 등으로 변환
    return currency.split(' ')[0];
  }
}
