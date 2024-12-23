import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/login/login_view_model.dart';
import 'package:flutter_market_app/ui/pages/social_id.dart';
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

  Future<void> _handleLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      print("폼 검증 실패");
      return;
    }

    print("===== 로그인 시도 시작 =====");
    print("폼 검증 통과");
    print("입력된 이메일: ${idController.text}");
    print("비밀번호 입력됨: ${pwController.text.isNotEmpty}");

    try {
      final viewModel = ref.read(loginViewmodel.notifier);

      final loginResult = await viewModel.login(
        email: idController.text.trim(),
        password: pwController.text.trim(),
      );

      if (loginResult == true) {
        print("로그인 성공 - 사용자 정보 초기화 시도");
        await viewModel.initUserData(ref);

        print("홈페이지로 이동 시도");
        if (mounted) {
          await viewModel.navigateToHome(context);
        }
      } else {
        print("로그인 실패");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      ref.read(loginViewmodel.notifier).handleError(context, e);
    }
  }

  Future<void> _handleSocialLogin(Future<bool> Function() signInMethod) async {
    try {
      final success = await signInMethod();
      if (success && mounted) {
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print("소셜 로그인 중 오류 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewmodel);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            Column(
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
                            LoginTextFormField(controller: idController),
                            SizedBox(height: 20),
                            PwTextFormField(controller: pwController),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  loginState.isLoading ? null : _handleLogin,
                              child: Text('로그인'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 52),
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildDivider(),
                            _buildSocialLoginButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
            if (loginState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        extendBody: true,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
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
    );
  }

  Widget _buildSocialLoginButtons() {
    return Consumer(
      builder: (context, ref, _) {
        final authService = ref.read(authServiceProvider);

        return authService.buildCircleSocialButtons(
          context,
          onKakaoTap: () => _handleSocialLogin(
            () => authService.onKakaoSignIn(context),
          ),
          onNaverTap: () => _handleSocialLogin(
            () => authService.onNaverSignIn(context),
          ),
          onGoogleTap: () => _handleSocialLogin(
            () => authService.onGoogleSignIn(context),
          ),
          onFacebookTap: () => _handleSocialLogin(
            () => authService.onFacebookSignIn(context),
          ),
          onAppleTap: () => _handleSocialLogin(
            () => authService.onAppleSignIn(context),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      height: 40,
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
    );
  }
}
