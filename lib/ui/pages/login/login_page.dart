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
  OverlayEntry? _loadingOverlay;

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

//로딩 오버레이를 표시하고 숨기는 메서드
  void _showLoadingOverlay() {
    _loadingOverlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    Overlay.of(context)!.insert(_loadingOverlay!);
  }

  void _hideLoadingOverlay() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
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
                                    _showLoadingOverlay(); // 로딩 오버레이 표시
                                    final viewModel = ref.read(loginViewmodel);
                                    print("로그인 viewModel 호출");
                                    final loginResult = await viewModel.login(
                                      email: idController.text,
                                      password: pwController.text,
                                    );
                                    print("로그인 결과: $loginResult");
                                    _hideLoadingOverlay(); // 로딩 오버레이 숨기기
                                    if (loginResult == true) {
                                      print("로그인 성공 - 사용자 정보 초기화 시도");
                                      await initUserData();
                                      print("홈페이지로 이동 시도");
                                      if (mounted) {
                                        // 로그인 성공 메시지를 표시하고 2초 동안 유지
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('로그인에 성공했습니다'),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );

                                        try {
                                          // 2초 대기 후 홈페이지로 이동
                                          await Future.delayed(
                                              Duration(seconds: 2));
                                          if (mounted) {
                                            // 페이드인 및 확대 애니메이션과 함께 홈페이지로 이동
                                            Navigator.of(context)
                                                .pushReplacement(
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    HomePage(),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  var begin = 0.0;
                                                  var end = 10.0;
                                                  var curve = Curves.easeInOut;

                                                  var fadeAnimation = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .animate(
                                                    CurvedAnimation(
                                                        parent: animation,
                                                        curve: curve),
                                                  );

                                                  var scaleAnimation = Tween(
                                                          begin: 0.1, end: 1.0)
                                                      .animate(
                                                    CurvedAnimation(
                                                        parent: animation,
                                                        curve: curve),
                                                  );

                                                  return FadeTransition(
                                                    opacity: fadeAnimation,
                                                    child: ScaleTransition(
                                                      scale: scaleAnimation,
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                transitionDuration:
                                                    Duration(milliseconds: 500),
                                              ),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('오류가 발생했습니다. 다시 시도해주세요.')),
                                      );
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('구글 로그인에 실패했습니다'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e, stackTrace) {
                                  print("===== 구글 로그인 에러 =====");
                                  print("에러 타입: ${e.runtimeType}");
                                  print("에러 메시지: $e");
                                  print("스택 트레이스: $stackTrace");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('로그인 중 오류가 발생했습니다'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
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
               
