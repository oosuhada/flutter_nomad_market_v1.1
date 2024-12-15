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
  late final String selectedLanguage;
  late final String selectedAddress;
  late final String selectedCurrency;
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.language;
    selectedAddress = widget.address;
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> onImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedImage != null) {
        setState(() {
          imageFile = File(pickedImage.path);
          imageUrl = pickedImage.path;
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지 선택 중 오류가 발생했습니다.")),
      );
    }
  }

  void onJoin() async {
    if (formKey.currentState?.validate() ?? false) {
      final viewModel = ref.watch(joinViewModel);
      try {
        final result = await viewModel.join(
          nickname: nicknameController.text,
          email: idController.text,
          password: pwController.text,
          addressFullName: widget.address,
          profileImageUrl: imageUrl ?? '',
        );
        if (result == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
            (route) => false,
          );
        } else {
          SnackbarUtil.showSnackBar(context, '회원가입에 실패하였습니다');
        }
      } catch (e) {
        print("회원가입 중 오류 발생: $e");
        SnackbarUtil.showSnackBar(context, '회원가입 중 오류가 발생했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              SizedBox(height: 20),
              Center(
                child: InkWell(
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
              // ... (소셜 로그인 버튼 등 나머지 코드)
            ],
          ),
        ),
      ),
    );
  }
}
