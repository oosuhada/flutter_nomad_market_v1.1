// 1. 상태 클래스 만들기 => Product 클래스 사용
// 2. 뷰모델 만들기
import 'package:flutter_market_app/data/model/product.dart';
import 'package:flutter_market_app/data/repository/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailViewModel extends AutoDisposeFamilyNotifier<Product?, int> {
  @override
  Product? build(int arg) {
    fetchDetail();
    return null;
  }

  final productRepository = ProductRepository();

  // 상품 상세 불러오기
  Future<void> fetchDetail() async {
    state = await productRepository.fetchDetail(arg);
  }

  // 좋아요
  Future<bool> like() async {
    final newLike = await productRepository.like(arg);
    if (newLike == null) {
      return false;
    }
    state = state?.copyWith(
      myLike: newLike,
    );
    return true;
  }

  // 삭제
  Future<bool> delete() async {
    return await productRepository.delete(arg);
  }
}

// 3. 뷰모델 관리자 만들기
final productDetailViewModel = NotifierProvider.autoDispose
    .family<ProductDetailViewModel, Product?, int>(() {
  return ProductDetailViewModel();
});
