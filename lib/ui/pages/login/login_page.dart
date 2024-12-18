// login_page.dart

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
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  // 로그인 성공 후 처리
  void _handleLoginSuccess(BuildContext context) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('로그인 성공'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e, stackTrace) {
      print("페이지 이동 중 오류 발생");
      print("에러: $e");
      print("스택트레이스: $stackTrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState.isLoading;
    final error = loginState.error;

    // 에러 메시지 표시
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $error')),
        );
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text(
                    '안녕하세요!\n이메일과 비밀번호로 로그인해주세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LoginTextFormField(controller: idController),
                  const SizedBox(height: 20),
                  PwTextFormField(controller: pwController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false))
                              return;

                            try {
                              final viewModel =
                                  ref.read(loginViewModelProvider.notifier);
                              await viewModel.login(
                                email: idController.text,
                                password: pwController.text,
                              );

                              if (!mounted) return;

                              if (viewModel.state.loginSuccess == true) {
                                await ref
                                    .read(userGlobalViewModel.notifier)
                                    .refreshUserData();
                                _handleLoginSuccess(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('로그인 실패')),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message = '로그인 실패';
                              switch (e.code) {
                                case 'user-not-found':
                                  message = '존재하지 않는 이메일입니다.';
                                  break;
                                case 'wrong-password':
                                  message = '잘못된 비밀번호입니다.';
                                  break;
                                default:
                                  message = '로그인 중 오류가 발생했습니다.';
                              }
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('로그인 중 오류가 발생했습니다')),
                              );
                            }
                          },
                    child: const Text('로그인'),
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
                      return Container(
                        width: double.infinity,
                        height: 52,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            final success =
                                await authService.onGoogleSignIn(context);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google 계정으로 가입되었습니다'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              await Future.delayed(Duration(seconds: 2));
                              if (!mounted) return;
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
                      );
                    },
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
