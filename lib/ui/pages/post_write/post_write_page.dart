import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_market_app/core/validator_util.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_write/%08post_write_view_model.dart';
import 'package:flutter_market_app/ui/pages/post_write/widgets/product_category_box.dart';
import 'package:flutter_market_app/ui/pages/post_write/widgets/post_write_picture_area.dart';
import 'package:flutter_market_app/ui/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostWritePage extends ConsumerStatefulWidget {
  final bool isRequesting;
  final Post? post;

  PostWritePage({required this.isRequesting, this.post});

  @override
  ConsumerState<PostWritePage> createState() => _PostWritePageState();
}

// State 클래스는 ConsumerState를 상속
class _PostWritePageState extends ConsumerState<PostWritePage> {
  late final titleController =
      TextEditingController(text: widget.post?.originalTitle ?? '');
  late final priceController =
      TextEditingController(text: widget.post?.price.amount.toString() ?? '');
  late final contentController =
      TextEditingController(text: widget.post?.originalDescription ?? '');
  final formKey = GlobalKey<FormState>();
  final _pictureAreaKey = GlobalKey<PostWritePictureAreaState>();

  String _tradeMethod = '';
  bool _isPriceNegotiable = false;
  bool _isSellButtonActive = false;
  bool _isShareButtonActive = false;
  bool _isRequestButtonActive = false;
  bool _isDeliveryButtonActive = false;

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("PostWritePage 초기화 시작"); // 페이지 초기화 시작 로그
    _initUserData();
  }

  Future<void> _initUserData() async {
    print("사용자 정보 초기화 시작");
    try {
      final userVM = ref.read(userGlobalViewModel.notifier);
      await userVM.initUserData();
      final userData = ref.read(userGlobalViewModel);
      print("사용자 정보 로드 완료:");
      print("- 사용자 ID: ${userData?.userId}");
      print("- 닉네임: ${userData?.nickname}");
    } catch (e) {
      print("사용자 정보 초기화 중 오류 발생: $e");
    }
  }

  Future<void> onSubmit() async {
    print("게시글 제출 프로세스 시작");
    final vm = ref.read(postWriteViewModel(widget.post).notifier);
    final userVM = ref.read(userGlobalViewModel);

    if (userVM == null) {
      print("사용자 정보 없음");
      return;
    }

    try {
      // 1. 로컬 이미지 업로드
      print("로컬 이미지 업로드 시작");
      final uploadedImages = await vm.uploadLocalImages();
      print("로컬 이미지 업로드 완료: ${uploadedImages.length}개");

      // 2. 로컬 PostSummary 생성
      final localPost = PostSummary(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        userId: userVM.userId,
        title: titleController.text,
        price: Price(
          amount: int.parse(priceController.text),
          currency: "KRW",
        ),
        negotiable: _isPriceNegotiable,
        thumbnail: FileModel(
          id: uploadedImages.isNotEmpty ? uploadedImages.first : '',
          url: uploadedImages.isNotEmpty ? uploadedImages.first : '',
          originName: '',
          contentType: 'image/jpeg',
          createdAt: DateTime.now().toIso8601String(),
        ),
        address: userVM.address,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: '', // 카테고리 정보 추가 필요
        likeCnt: 0,
        status: 'ACTIVE',
      );

      // 3. 로컬 상태 업데이트 및 네비게이션
      final homeTabVM = ref.read(homeTabViewModel.notifier);
      homeTabVM.addLocalPost(localPost);

      if (mounted) {
        Navigator.pop(context);
      }

      // 4. 백그라운드에서 서버 업로드 진행
      print("서버 업로드 시작");
      final result = await vm.upload(
        originalTitle: titleController.text,
        translatedTitle: titleController.text, // 실제 번역 로직 필요
        price: Price(amount: int.parse(priceController.text), currency: "KRW"),
        originalDescription: contentController.text,
        translatedDescription: contentController.text, // 실제 번역 로직 필요
        location: userVM.address.fullNameKR,
        userNickname: userVM.nickname,
        userProfileImageUrl: userVM.profileImageUrl,
        userHomeAddress: userVM.address.fullNameKR,
      );

      if (result != null) {
        print("서버 업로드 성공");
        // 서버 업로드 성공 후 홈탭 새로고침
        await homeTabVM.refreshPosts();
      } else {
        print("서버 업로드 실패");
        // 업로드 실패 시 에러 처리
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('게시글 업로드에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    } catch (e, stackTrace) {
      print("게시글 처리 중 오류 발생:");
      print("- 오류 유형: ${e.runtimeType}");
      print("- 오류 내용: $e");
      print("- 스택 트레이스: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 작성 중 오류가 발생했습니다')),
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
        appBar: AppBar(
          title: Text(widget.isRequesting ? '물품 의뢰하기' : '내 물건 판매'),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              PostWritePictureArea(widget.post),
              SizedBox(height: 20),
              ProductCategoryBox(widget.post),
              SizedBox(height: 20),
              Text('거래 방식', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: widget.isRequesting
                    ? [
                        _buildTradeMethodButton('구매요청', Icons.shopping_cart,
                            _isRequestButtonActive),
                        _buildTradeMethodButton('전달요청', Icons.local_shipping,
                            _isDeliveryButtonActive),
                      ]
                    : [
                        _buildTradeMethodButton(
                            '판매하기', Icons.sell, _isSellButtonActive),
                        _buildTradeMethodButton(
                            '나눔하기', Icons.card_giftcard, _isShareButtonActive),
                      ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '상품명을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorTitle,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '가격을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorPrice,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _isPriceNegotiable,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPriceNegotiable = value ?? false;
                      });
                    },
                  ),
                  Text('가격 제안 받기'),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '내용을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorContent,
              ),
              SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () async {
                    print("작성 완료 버튼 클릭");

                    // 폼 검증
                    final isFormValid =
                        formKey.currentState?.validate() ?? false;
                    print("폼 검증 결과: $isFormValid");

                    if (!isFormValid) {
                      print("폼 검증 실패:");
                      print("- 제목: ${titleController.text}");
                      print("- 가격: ${priceController.text}");
                      print("- 내용: ${contentController.text}");
                      print("- 거래 방식: $_tradeMethod");
                      return;
                    }

                    print("폼 검증 통과, 게시글 업로드 시작");

                    try {
                      await onSubmit();
                      print("게시글 업로드 완료");

                      if (mounted) {
                        print("홈 탭 새로고침 시작");
                        await ref.read(homeTabViewModel.notifier).fetchPosts();
                        print("홈 탭 새로고침 완료");
                        Navigator.pop(context);
                      }
                    } catch (e, stackTrace) {
                      print("게시글 작성 중 오류 발생:");
                      print("- 오류 유형: ${e.runtimeType}");
                      print("- 오류 내용: $e");
                      print("- 스택 트레이스: $stackTrace");

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('게시글 작성 중 오류가 발생했습니다')),
                        );
                      }
                    }
                  },
                  child: Text('작성 완료'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeMethodButton(String label, IconData icon, bool isActive) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _tradeMethod = label;
            _isSellButtonActive = label == '판매하기';
            _isShareButtonActive = label == '나눔하기';
            _isRequestButtonActive = label == '구매요청';
            _isDeliveryButtonActive = label == '전달요청';
          });
        },
        icon: Icon(
          icon,
          color: isActive
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
          elevation: isActive ? 2 : 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: Size(0, 0),
        ),
      ),
    );
  }
}
