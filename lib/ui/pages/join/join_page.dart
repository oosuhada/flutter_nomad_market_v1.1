import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/home/home_page.dart';
import 'package:flutter_market_app/ui/pages/join/join_view_model.dart';
import 'package:flutter_market_app/ui/pages/social_id.dart';
import 'package:flutter_market_app/ui/widgets/join_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/nickname_text_form_field.dart';
import 'package:flutter_market_app/ui/widgets/pw_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    super.dispose();
  }

  Future<void> _handleSocialSignUp(Future<bool> Function() signUpMethod) async {
    try {
      final success = await signUpMethod();
      if (success && mounted) {
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print("소셜 회원가입 중 오류 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 중 오류가 발생했습니다')),
        );
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
              JoinTextFormField(controller: emailController),
              SizedBox(height: 20),
              PwTextFormField(controller: pwController),
              SizedBox(height: 20),
              NicknameTextFormField(controller: nicknameController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(joinViewModel.notifier).onJoin(
                        context: context,
                        email: emailController.text,
                        password: pwController.text,
                        nickname: nicknameController.text,
                        selectedAddress: selectedAddress,
                        selectedLanguage: selectedLanguage,
                        selectedCurrency: selectedCurrency,
                      );
                },
                child: Text('회원가입'),
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
          onKakaoTap: () => _handleSocialSignUp(
            () => authService.onKakaoSignUp(
              context,
              language: selectedLanguage,
              currency: selectedCurrency,
              addressFullName: selectedAddress,
            ),
          ),
          onNaverTap: () => _handleSocialSignUp(
            () => authService.onNaverSignUp(
              context,
              language: selectedLanguage,
              currency: selectedCurrency,
              addressFullName: selectedAddress,
            ),
          ),
          onGoogleTap: () => _handleSocialSignUp(
            () => authService.onGoogleSignUp(
              context,
              language: selectedLanguage,
              currency: selectedCurrency,
              addressFullName: selectedAddress,
            ),
          ),
          onFacebookTap: () => _handleSocialSignUp(
            () => authService.onFacebookSignUp(
              context,
              language: selectedLanguage,
              currency: selectedCurrency,
              addressFullName: selectedAddress,
            ),
          ),
          onAppleTap: () => _handleSocialSignUp(
            () => authService.onAppleSignUp(
              context,
              language: selectedLanguage,
              currency: selectedCurrency,
              addressFullName: selectedAddress,
            ),
          ),
        );
      },
    );
  }
}
