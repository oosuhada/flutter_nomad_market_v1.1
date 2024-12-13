import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/ui/pages/_tab/my_tab/widgets/profile_edit_view_model.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditViewModel.notifier).initUserData();
    });
  }

  @override
  void dispose() {
    pwController.dispose();
    nicknameController.dispose();
    super.dispose();
  }


  // void onImageUpload() async {
  //   final result = await ImagePickerHelper.pickImage();
  //   if (result != null) {
  //     final viewModel = ref.read(profileEditViewModel.notifier);
  //     viewModel.uploadImage(
  //       filename: result.filename,
  //       mimeType: result.mimeType,
  //       bytes: result.bytes,
  //     );
  //   }
  // }

  void navigateToMyTab() {
    // Reset to the first route (home)
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Set the home view model index to 2 (MyTab)
    ref.read(homeViewModel.notifier).onIndexChanged(2);
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileEditViewModel);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('프로필 수정'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: profileData?.profileImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Image.network(
                            profileData!.profileImage!.url,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 60),
                            SizedBox(height: 4),
                            Text('프로필 사진'),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: '새로운 닉네임을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final viewModel = ref.read(profileEditViewModel.notifier);

                      final result = await viewModel.updateProfile(
                        nickname: nicknameController.text.trim(),
                      );

                      if (result) {
                        // 성공 시 MyTab으로 이동
                        if (mounted) {
                          navigateToMyTab();
                        }
                      } else {
                        // 실패 시 에러 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('프로필 업데이트에 실패했습니다.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade900,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 8,
                  ),
                  child: Text(
                    '변경하기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
