import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_view_model.dart';
import 'package:flutter_market_app/ui/pages/social_id.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_market_app/ui/widgets/login_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key); // 생성자 추가

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void onGoogleSignIn() {
    final authService = ref.read(authServiceProvider);
    authService.onGoogleSignIn(context);
  }

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> initUserData() async {
    print("사용자 정보 초기화 시작");
    try {
      final userVM = ref.read(userGlobalViewModel.notifier);
      await userVM.initUserData();
      final userData = ref.read(userGlobalViewModel);
      print("사용자 정보 로드 완료:");
      print("- 사용자 ID: ${userData?.userId}");
      print("- 닉네임: ${userData?.nickname}");
    } catch (e) {
      print("사용자 정보 초기화 중 오류 발생: $e");
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
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        LoginTextFormField(controller: idController),
                        SizedBox(height: 20),
                        PwTextFormField(controller: pwController),
                        SizedBox(height: 20),
                        Consumer(
                          builder: (context, ref, child) {
                            return ElevatedButton(
                              onPressed: () async {
                                print("===== 로그인 시도 시작 =====");
                                if (formKey.currentState?.validate() ?? false) {
                                  print("폼 검증 통과");
                                  print("입력된 이메일: ${idController.text}");
                                  print(
                                      "비밀번호 입력됨: ${pwController.text.isNotEmpty}");
                                  try {
                                    final viewModel = ref.read(loginViewmodel);
                                    print("로그인 viewModel 호출");
                                    final loginResult = await viewModel.login(
                                      email: idController.text,
                                      password: pwController.text,
                                    );
                                    print("로그인 결과: $loginResult");
                                    if (loginResult == true) {
                                      print("로그인 성공 - 사용자 정보 초기화 시도");
                                      await initUserData();
                                      print("홈페이지로 이동 시도");
                                      if (mounted) {
                                        try {
                                          await Future.delayed(Duration(
                                              milliseconds: 100)); // 약간의 지연 추가
                                          if (mounted) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage(),
                                              ),
                                              (route) => false,
                                            );
                                            print("홈페이지 이동 완료");
                                          }
                                        } catch (e, stackTrace) {
                                          print("홈페이지 이동 중 오류 발생");
                                          print("에러: $e");
                                          print("스택트레이스: $stackTrace");
                                        }
                                      }
                                    } else {
                                      print("로그인 실패");
                                    }
                                  } on FirebaseAuthException catch (e, stackTrace) {
                                    print("===== Firebase 인증 에러 =====");
                                    print("에러 코드: ${e.code}");
                                    print("에러 메시지: ${e.message}");
                                    print("스택 트레이스: $stackTrace");
                                  } catch (e, stackTrace) {
                                    print("===== 일반 에러 =====");
                                    print("에러 타입: ${e.runtimeType}");
                                    print("에러 메시지: $e");
                                    print("스택 트레이스: $stackTrace");
                                  }
                                } else {
                                  print("폼 검증 실패");
                                }
                              },
                              child: Text('로그인'),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                print("===== 구글 로그인 시도 시작 =====");
                                try {
                                  final authService =
                                      ref.read(authServiceProvider);
                                  print("구글 로그인 서비스 호출");

                                  final success =
                                      await authService.onGoogleSignIn(context);
                                  print("구글 로그인 결과: $success");

                                  if (success) {
                                    print("구글 로그인 성공 - 스낵바 표시");
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('구글 계정으로 로그인되었습니다'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }

                                    print("딜레이 시작");
                                    await Future.delayed(Duration(seconds: 1));
                                    print("딜레이 완료");

                                    if (mounted) {
                                      print("홈페이지로 이동 시도");
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                        (route) => false,
                                      );
                                      print("홈페이지 이동 완료");
                                    } else {
                                      print("위젯이 더 이상 마운트되지 않음");
                                    }
                                  } else {
                                    print("구글 로그인 실패");
                                  }
                                } catch (e, stackTrace) {
                                  print("===== 구글 로그인 에러 =====");
                                  print("에러 타입: ${e.runtimeType}");
                                  print("에러 메시지: $e");
                                  print("스택 트레이스: $stackTrace");
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final success = await authService
                                        .onGoogleSignIn(context);
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('구글 계정으로 로그인되었습니다'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      await Future.delayed(
                                          Duration(seconds: 1));

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.white,
                                    foregroundColor:
                                        Theme.of(context).brightness ==
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false, // 이 속성 추가
        extendBody: true, // 이 속성 추가
        bottomNavigationBar: Container(
          height: 40, // 하단바 높이 조정
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(child: SizedBox(width: 10)),
                    TextSpan(
                      text: "비밀번호를 잊으셨습니까?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(text: " "),
                    TextSpan(
                      text: "계정찾기",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    WidgetSpan(child: SizedBox(width: 10)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
               
