import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// 게시글 작성 화면의 이미지 업로드 영역을 담당하는 위젯
class PostWritePictureArea extends StatefulWidget {
  PostWritePictureArea(this.post);
  final Post? post;

  @override
  State<PostWritePictureArea> createState() => _PostWritePictureAreaState();
}

class _PostWritePictureAreaState extends State<PostWritePictureArea> {
  // 로컬에서 선택된 이미지들을 저장하는 리스트
  List<File> _localImages = [];

  // 이미지 업로드 시 에러 메시지를 저장하는 변수
  String? _errorMessage;

  // 이미지 업로드 처리 메서드
  Future<void> _handleImageUpload(WidgetRef ref, XFile image) async {
    print("===== 이미지 업로드 시작 =====");
    print("파일명: ${image.name}");

    try {
      final file = File(image.path);
      print("파일 경로: ${file.path}");

      final bytes = await file.readAsBytes();
      print("파일 크기: ${bytes.length} bytes");

      final vm = ref.read(postWriteViewModel(widget.post).notifier);
      print("이미지 업로드 시도");

      await vm.uploadImage(
        filename: image.name,
        mimeType: 'image/jpeg',
        bytes: bytes,
      );
      print("이미지 업로드 성공");

      setState(() {
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      print("===== 이미지 업로드 중 에러 발생 =====");
      print("에러 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(postWriteViewModel(widget.post));
      print("===== PostWritePictureArea 빌드 =====");
      print("현재 이미지 파일 수: ${state.imageFiles.length}");
      print("로컬 이미지 수: ${_localImages.length}");

      // 서버에 업로드된 이미지와 로컬 이미지를 합친 리스트 생성
      final images = [
        ...state.imageFiles.map((e) => _buildNetworkImage(e.url)),
        ..._localImages.map((file) => _buildLocalImage(file)),
      ];

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
                ...images,
                _buildImagePickerButton(context, ref, state),
              ],
            ),
          ),
        ],
      );
    });
  }

  // 네트워크 이미지 위젯 생성
  Widget _buildNetworkImage(String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("이미지 로드 실패: $error");
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.error),
              );
            },
          ),
        ),
      ),
    );
  }

  // 로컬 이미지 위젯 생성
  Widget _buildLocalImage(File file) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // 이미지 선택 버튼 위젯 생성
  Widget _buildImagePickerButton(
    BuildContext context,
    WidgetRef ref,
    PostWriteState state,
  ) {
    return GestureDetector(
      onTap: () async {
        print("이미지 선택 버튼 클릭");
        final ImagePicker _picker = ImagePicker();

        try {
          final List<XFile> pickedImages = await _picker.pickMultiImage(
            imageQuality: 70,
            maxWidth: 1000,
            maxHeight: 1000,
          );
          print("선택된 이미지 수: ${pickedImages.length}");

          if (pickedImages.isNotEmpty) {
            for (var image in pickedImages) {
              if (_localImages.length + state.imageFiles.length < 10) {
                setState(() {
                  _localImages.add(File(image.path));
                });
                await _handleImageUpload(ref, image);
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
                '${state.imageFiles.length + _localImages.length}/10',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
