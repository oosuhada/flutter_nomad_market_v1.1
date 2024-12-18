import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/social_id.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/join_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/nickname_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? imageFile;
  String? imageUrl;
  late final String selectedLanguage;
  late final String selectedAddress;
  late final String selectedCurrency;

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
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(context).pop();
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    imageFile = File(image.path);
                    imageUrl = image.path;
                  });
                }
              },
              child: Text(
                '갤러리에서 선택',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(context).pop();
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    imageFile = File(image.path);
                    imageUrl = image.path;
                  });
                }
              },
              child: Text(
                '카메라로 촬영',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '취소',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text('오류', style: theme.textTheme.titleSmall),
          content: Text(message,
              style: TextStyle(
                color: theme.listTileTheme.textColor,
                fontSize: 16,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> onJoin() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = pwController.text.trim();
    final nickname = nicknameController.text.trim();

    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      SnackbarUtil.showSnackBar(context, '모든 필드를 입력해주세요');
      return;
    }

    try {
      final viewModel = ref.read(joinViewModelProvider.notifier);
      await viewModel.join(
        nickname: nickname,
        email: email,
        password: password,
        addressFullName: widget.address,
        language: widget.language.split(' ')[0].toLowerCase(),
        currency: widget.currency.split(' ')[0],
      );

      if (viewModel.state.joinSuccess == true) {
        await ref.read(userGlobalViewModel.notifier).refreshUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 성공적으로 완료되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        if (!mounted) return;
        SnackbarUtil.showSnackBar(context, '회원가입에 실패했습니다');
      }
    } catch (e) {
      print("회원가입 중 오류 발생: $e");
      if (!mounted) return;
      SnackbarUtil.showSnackBar(context, '회원가입 중 오류가 발생했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userGlobalViewModel);
    final error = userState.error;

    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $error')),
        );
      });
    }

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Google 계정으로 가입되었습니다'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        await Future.delayed(Duration(seconds: 2));
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
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
    final languageMap = {
      "한국어": "ko",
      "English": "en",
    };
    return languageMap[language] ?? "ko";
  }

  static String formatCurrency(String currency) {
    return currency.split(' ')[0];
  }
}
