import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/_tab/my_tab/widgets/profile_edit_view_model.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
    print('onImageUpload 함수 시작');
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        print('CupertinoActionSheet 빌더 호출');
        final theme = Theme.of(context);
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                print('갤러리 선택 버튼 클릭');
                Navigator.of(context).pop();
                await pickAndShowImage(ImageSource.gallery);
              },
              child: Text('갤러리에서 선택',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                print('카메라 촬영 버튼 클릭');
                Navigator.of(context).pop();
                await pickAndShowImage(ImageSource.camera);
              },
              child: Text('카메라로 촬영',
                  style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              print('취소 버튼 클릭');
              Navigator.of(context).pop();
            },
            child: Text('취소',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color, fontSize: 16)),
          ),
        );
      },
    );
    print('onImageUpload 함수 종료');
  }

  Future<void> pickAndShowImage(ImageSource source) async {
    print('pickAndShowImage 함수 시작');
    final XFile? pickedFile = await pickImage(source);
    if (pickedFile != null) {
      await showLocalImage(pickedFile);
      await uploadImage(pickedFile);
    }
    print('pickAndShowImage 함수 종료');
  }

  Future<XFile?> pickImage(ImageSource source) async {
    print('이미지 선택 시작');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    print('이미지 선택 완료: ${image?.path}');
    return image;
  }

  Future<void> showLocalImage(XFile file) async {
    print('로컬 이미지 표시 시작');
    setState(() {
      _imageFile = File(file.path);
    });
    print('로컬 이미지 표시 완료');
  }

  Future<void> uploadImage(XFile file) async {
    print('이미지 업로드 시작');
    try {
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final viewModel = ref.read(profileEditViewModel.notifier);
      await viewModel.uploadImage(
        filename: fileName,
        mimeType: 'image/jpeg',
        bytes: bytes,
      );
      print('이미지 업로드 완료');
    } catch (e) {
      print('이미지 업로드 오류: $e');
      SnackbarUtil.showSnackBar(context, '이미지 업로드에 실패했습니다');
    }
  }

  void navigateToMyTab() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(homeViewModel.notifier).onIndexChanged(2);
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileEditViewModel);
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
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 90,
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
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
                        imageFile: _imageFile,
                      );
                      if (result) {
                        if (mounted) {
                          navigateToMyTab();
                        }
                      } else {
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
