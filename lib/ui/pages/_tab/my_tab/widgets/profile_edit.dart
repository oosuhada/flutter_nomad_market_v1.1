import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/ui/pages/_tab/my_tab/widgets/profile_edit_view_model.dart';
import 'package:flutter_market_app/ui/pages/home/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
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
    print('onImageUpload');
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery, // 갤러리에서 선택
      imageQuality: 50, // 이미지 품질 (0~100)
    );
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path); // 선택한 이미지 파일 저장
      });
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
            Center(
              child: GestureDetector(
                onTap: onImageUpload,
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : profileData?.profileImage != null
                                ? CachedNetworkImage(
                                    imageUrl: profileData!.profileImage!.url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                : Icon(Icons.person_outline,
                                    size: 50, color: Colors.grey[400]),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
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
