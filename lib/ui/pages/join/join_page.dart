import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/welcome/welcome_page.dart';
import 'package:flutter_market_app/ui/widgets/id_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/nickname_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  void onImageUpload() async {
    print('onImageUpload');
    final result = await ImagePickerHelper.pickImage();
    if (result != null) {
      final viewModel = ref.read(joinViewModel.notifier);
      viewModel.uploadImage(
        filename: result.filename,
        mimeType: result.mimeType,
        bytes: result.bytes,
      );
    }
  }

  void onJoin() async {
    if (formKey.currentState?.validate() ?? false) {
      final viewModel = ref.read(joinViewModel.notifier);

      final validateResult = await viewModel.validateName(
        username: idController.text,
        nickname: nicknameController.text,
      );

      if (validateResult != null) {
        SnackbarUtil.showSnackBar(context, validateResult);
        return;
      }

      final result = await viewModel.join(
        username: idController.text,
        password: pwController.text,
        nickname: nicknameController.text,
        addressFullName: widget.address,
      );
      if (result) {
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
    final fileModel = ref.watch(joinViewModel);
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
                '안녕하세요!\n아이디와 비밀본호로 가입해주세요',
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: fileModel != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              fileModel.url,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 30,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '프로필 사진',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
