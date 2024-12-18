import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/_tab/my_tab/widgets/profile_edit_view_model.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final nicknameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditViewModel.notifier).initUserData();
    });
  }

  @override
  void dispose() {
    nicknameController.dispose();
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
                await pickAndShowImage(ImageSource.gallery);
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
                await pickAndShowImage(ImageSource.camera);
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

  Future<void> pickAndShowImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // 프로필 이미지 업로드를 ViewModel에 전달
      final bytes = await _imageFile!.readAsBytes();
      final fileName = pickedFile.name;
      await ref.read(profileEditViewModel.notifier).uploadImage(
            filename: fileName,
            mimeType: 'image/jpeg',
            bytes: bytes,
          );
    }
  }

  void navigateToMyTab() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(homeViewModel.notifier).onIndexChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileEditViewModel);

    if (profileData != null) {
      nicknameController.text = profileData.nickname ?? '';
    }

    return Scaffold(
      appBar: AppBar(title: Text('프로필 수정')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
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
                    child: _imageFile != null
                        ? ClipOval(
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : profileData?.profileImageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  profileData!.profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.person, size: 90),
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
                        profileImageUrl: viewModel.state?.profileImageUrl ?? '',
                      );
                      if (result) {
                        if (mounted) {
                          SnackbarUtil.showSnackBar(
                              context, "프로필이 성공적으로 업데이트되었습니다.");
                          navigateToMyTab();
                        }
                      } else {
                        SnackbarUtil.showSnackBar(context, "프로필 업데이트에 실패했습니다.");
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
