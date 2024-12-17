import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PostWritePictureArea extends ConsumerStatefulWidget {
  PostWritePictureArea(this.post);
  final Post? post;

  @override
  ConsumerState<PostWritePictureArea> createState() =>
      PostWritePictureAreaState();
}

class PostWritePictureAreaState extends ConsumerState<PostWritePictureArea> {
  // 로컬에서 선택된 이미지들을 저장하는 리스트
  List<File> _localImages = [];
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print("===== PostWritePictureArea initState =====");
    // 초기화 시 ViewModel에 현재 상태 전달
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncImagesWithViewModel();
    });
  }

  // ViewModel과 이미지 상태 동기화
  void _syncImagesWithViewModel() {
    print("이미지 상태 동기화 시작");
    if (_localImages.isNotEmpty) {
      final vm = ref.read(postWriteViewModel(widget.post).notifier);
      vm.addLocalImages(_localImages);
      print("ViewModel에 ${_localImages.length}개 이미지 동기화 완료");
    }
  }

  // 이미지 선택 및 처리
  Future<void> getLocalImages() async {
    print("===== 로컬 이미지 선택 시작 =====");
    print("현재 로컬 이미지 수: ${_localImages.length}");

    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedImages.isNotEmpty) {
        final vm = ref.read(postWriteViewModel(widget.post).notifier);
        final newImages =
            pickedImages.map((xFile) => File(xFile.path)).toList();

        // 이미지 개수 제한 확인
        final totalImages = _localImages.length + newImages.length;
        if (totalImages <= 10) {
          setState(() {
            _localImages.addAll(newImages);
          });
          // ViewModel에도 이미지 추가
          vm.addLocalImages(newImages);
          print("로컬 이미지 ${newImages.length}개 추가 완료");
        } else {
          print("최대 이미지 수 초과");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('최대 10장까지만 선택할 수 있습니다.')),
          );
        }
      }
    } catch (e) {
      print("이미지 선택 중 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
      );
    }
  }

  // 이미지 선택 버튼 위젯 생성
  Widget _buildImagePickerButton(BuildContext context, PostWriteState state) {
    return GestureDetector(
      onTap: getLocalImages,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.grey),
              Text(
                '${state.localImageFiles.length + _localImages.length}/10',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로컬 이미지 위젯 생성
  Widget _buildLocalImage(File imageFile) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postWriteViewModel(widget.post));
    print("===== PostWritePictureArea 빌드 =====");
    print("현재 이미지 파일 수: ${state.localImageFiles.length}");
    print("로컬 이미지 수: ${_localImages.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._localImages.map(_buildLocalImage),
              _buildImagePickerButton(context, state),
            ],
          ),
        ),
      ],
    );
  }
}
