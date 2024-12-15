import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_view_model.dart';
import 'package:flutter_market_app/ui/widgets/join_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/login_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
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
                '안녕하세요!\n이메일과 비밀번호로 로그인해주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(child: SizedBox(width: 20)),
                      WidgetSpan(child: SizedBox(width: 20)),
                      TextSpan(
                        text: "계정찾기",
                        style: TextStyle(
                          color: Color(0xFF98A8EA),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      WidgetSpan(child: SizedBox(width: 10)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              LoginTextFormField(controller: idController),
              SizedBox(height: 20),
              PwTextFormField(controller: pwController),
              SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    // 벨리데이션 성공했을 때, 로그인 요청
                    if (formKey.currentState?.validate() ?? false) {
                      final viewModel = ref.read(loginViewmodel);
                      final loginResult = await viewModel.login(
                        email: idController.text,
                        password: pwController.text,
                      );
                      if (loginResult == true) {
                        // 로그인 성공 => HomePage로 이동.(모든페이지를 제거한뒤 가야함)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return HomePage();
                            },
                          ),
                          // 기존 네이게이터 스택에 남아있는 페이지들이 하나씩
                          // route라는 인자로 넘어와서 함수가 실행됨
                          // 페이지 스택에 남길지 여부 리턴!
                          (route) {
                            return false;
                          },
                        );
                      } else {
                        // 로그인 실패 => 스낵바!
                        SnackbarUtil.showSnackBar(context, '이메일과 비밀번호를 확인해주세요');
                      }
                    }
                  },
                  child: Text('로그인'),
                );
              }),

              SizedBox(height: 10),

              // 소셜 로그인 구분선
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
                            child: ElevatedButton(
                              onPressed: () => onGoogleSignIn(ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                                foregroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[100]
                                    : Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.25),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/google_logo.png',
                                      height: 24,
                                    ),
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
                          )),

                      // 페이스북 로그인 버튼
                      // GestureDetector(
                      //   onTap: () => onFacebookSignIn(ref),
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 52,
                      //     margin: EdgeInsets.symmetric(vertical: 10),
                      //     decoration: BoxDecoration(
                      //       color:
                      //           Theme.of(context).brightness == Brightness.dark
                      //               ? Colors.grey[900]
                      //               : Colors.white,
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(color: Colors.grey.shade600),
                      //     ),
                      //     child: Center(
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         children: [
                      //           SizedBox(width: 15),
                      //           Icon(
                      //             Icons.facebook,
                      //             color: const Color.fromARGB(255, 33, 47, 125),
                      //             size: 40,
                      //           ),
                      //           SizedBox(width: 10),
                      //           Text(
                      //             '페이스북 아이디로 계속하기',
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //               color: Theme.of(context).brightness ==
                      //                       Brightness.dark
                      //                   ? Colors.grey[400]
                      //                   : Colors.grey[600],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
