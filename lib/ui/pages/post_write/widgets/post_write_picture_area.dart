import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// 게시글 작성 화면의 이미지 업로드 영역을 담당하는 위젯
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

  // 이미지 업로드 시 에러 메시지를 저장하는 변수
  String? _errorMessage;

  // 저장된 로컬 이미지 목록을 반환하는 메서드
  void getLocalImages() async {
    print("===== 로컬 이미지 목록 반환 =====");
    print("로컬 이미지 수: ${_localImages.length}");

    final ImagePicker _picker = ImagePicker();
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedImages.isNotEmpty) {
        final vm = ref.read(postWriteViewModel(widget.post).notifier);
        for (var image in pickedImages) {
          if (_localImages.length + vm.state.uploadedImageFiles.length < 10) {
            // 선택한 이미지를 로컬 상태에 추가
            setState(() {
              _localImages.add(File(image.path));
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('최대 10장까지만 선택할 수 있습니다.')),
            );
            break;
          }
        }
      }
    } catch (e) {
      print("이미지 선택 중 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
      );
    }
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
        // 에러 메시지 표시
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        // 이미지 목록 및 선택 버튼
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

  Widget _buildLocalImage(File imageFile) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // 이미지 선택 버튼 위젯 생성
  Widget _buildImagePickerButton(
    BuildContext context,
    PostWriteState state,
  ) {
    return GestureDetector(
      onTap: () async {
        print("===== 이미지 선택 시작 =====");
        final ImagePicker _picker = ImagePicker();

        try {
          // 이미지 다중 선택
          final List<XFile> pickedImages = await _picker.pickMultiImage(
            imageQuality: 70,
            maxWidth: 1000,
            maxHeight: 1000,
          );
          print("선택된 이미지 수: ${pickedImages.length}");

          // 선택된 이미지가 있는 경우 처리
          if (pickedImages.isNotEmpty) {
            for (var image in pickedImages) {
              // 최대 10장 제한 확인
              if (_localImages.length + state.localImageFiles.length < 10) {
                print("이미지 추가: ${image.path}");
                setState(() {
                  _localImages.add(File(image.path));
                });
                // 작성 완료 버튼 클릭 시 업로드하도록 변경
              } else {
                print("최대 이미지 수 초과");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('최대 10장까지만 선택할 수 있습니다.')),
                );
                break;
              }
            }
          }
        } catch (e) {
          print("이미지 선택 중 에러: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
          );
        }
      },
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

  // // 네트워크 이미지 위젯 생성 메서드 (구현 필요)
  // Widget _buildNetworkImage(String url) {
  //   // TODO: 네트워크 이미지 위젯 구현
  //   return Container();
  // }

  // // 로컬 이미지 위젯 생성 메서드 (구현 필요)
  // Widget _buildLocalImage(File file) {
  //   // TODO: 로컬 이미지 위젯 구현
  //   return Container();
  // }
}
