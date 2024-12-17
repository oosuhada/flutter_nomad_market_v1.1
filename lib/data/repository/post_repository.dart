// post_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import '../model/file_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 게시글 요약 목록을 조회하는 메서드
  // addressId: 지역 필터링
  // status: 거래 상태 필터링
  // type: 판매/구매 구분 필터링
  // language: 언어 필터링
  // currency: 통화 필터링
  Future<List<PostSummary>> getPostSummaries({
    String? addressId,
    PostStatus? status,
    PostType? type,
    String? language,
    String? currency,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('posts');

      // 필터 조건 적용
      if (addressId != null) {
        query = query.where('address.id', isEqualTo: addressId);
      }
      if (status != null) {
        query =
            query.where('status', isEqualTo: status.toString().split('.').last);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }
      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }
      if (currency != null) {
        query = query.where('price.currency', isEqualTo: currency);
      }

      // 최신 수정순으로 정렬
      query = query.orderBy('updatedAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PostSummary.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('게시글 요약 목록 조회 중 오류 발생: $e');
      return [];
    }
  }

  // 거래 상태에 따른 한글 라벨을 반환하는 메서드
  String getStatusLabel(PostStatus status, PostType type) {
    switch (status) {
      case PostStatus.active:
        return type == PostType.selling ? "판매중" : "구매중";
      case PostStatus.completed:
        return "거래완료";
      case PostStatus.reserved:
        return "예약중";
    }
  }

  // 새로운 게시글을 생성하는 메서드
  Future<Post?> createPost({
    required String userId,
    required String originalTitle,
    required String translatedTitle,
    required List<FileModel> images,
    required String category,
    required Price price,
    required PostType type,
    required PostStatus status,
    required bool negotiable,
    required String originalDescription,
    required String translatedDescription,
    required Address address,
    required String userNickname,
    required String userProfileImageUrl,
    required Address userAddress, // 사용자 주소 정보 추가
    required String language, // 언어 정보 추가
  }) async {
    try {
      final docRef = _firestore.collection('posts').doc();
      final thumbnail = images.first;

      final post = Post(
        postId: docRef.id,
        userId: userId,
        originalTitle: originalTitle,
        translatedTitle: translatedTitle,
        price: price,
        category: category,
        type: type,
        status: status,
        negotiable: negotiable,
        originalDescription: originalDescription,
        translatedDescription: translatedDescription,
        images: images,
        thumbnail: thumbnail,
        address: address,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userNickname: userNickname,
        userProfileImageUrl: userProfileImageUrl,
        userAddress: userAddress,
        language: language,
      );

      await docRef.set(post.toJson());
      return post;
    } catch (e) {
      print('게시글 생성 중 오류 발생: $e');
      return null;
    }
  }

  // 게시글 상세 조회 메서드 (주소 및 언어 정보 포함)
  Future<Post?> getPostDetails(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('게시글 상세 조회 중 오류 발생: $e');
      return null;
    }
  }
}

// 가격 정보를 관리하는 Repository 클래스
class PriceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 특정 통화의 가격 범위 조회
  Future<Map<String, num>> getPriceRange(String currency) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('price.currency', isEqualTo: currency)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'min': 0, 'max': 0};
      }

      final prices = querySnapshot.docs
          .map((doc) => (doc.data()['price'] as Map)['amount'] as num)
          .toList();

      return {
        'min': prices.reduce((min, price) => price < min ? price : min),
        'max': prices.reduce((max, price) => price > max ? price : max),
      };
    } catch (e) {
      print('가격 범위 조회 중 오류 발생: $e');
      return {'min': 0, 'max': 0};
    }
  }

  // 통화별 평균 가격 조회
  Future<Map<String, double>> getAveragePricesByCurrency() async {
    try {
      final querySnapshot = await _firestore.collection('posts').get();
      final Map<String, List<num>> pricesByCurrency = {};

      for (var doc in querySnapshot.docs) {
        final price = doc.data()['price'] as Map;
        final currency = price['currency'] as String;
        final amount = price['amount'] as num;

        if (!pricesByCurrency.containsKey(currency)) {
          pricesByCurrency[currency] = [];
        }
        pricesByCurrency[currency]!.add(amount);
      }

      final Map<String, double> averagePrices = {};
      pricesByCurrency.forEach((currency, prices) {
        final average = prices.reduce((a, b) => a + b) / prices.length;
        averagePrices[currency] = average;
      });

      return averagePrices;
    } catch (e) {
      print('평균 가격 조회 중 오류 발생: $e');
      return {};
    }
  }

  // 가격 필터링을 위한 범위 설정 메서드
  Future<List<Post>> getPostsByPriceRange({
    required String currency,
    required num minPrice,
    required num maxPrice,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('price.currency', isEqualTo: currency)
          .where('price.amount', isGreaterThanOrEqualTo: minPrice)
          .where('price.amount', isLessThanOrEqualTo: maxPrice)
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('가격 범위 필터링 중 오류 발생: $e');
      return [];
    }
  }

  // 특정 통화의 최저가 게시글 조회
  Future<List<Post>> getLowestPricePosts({
    required String currency,
    required int limit,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('price.currency', isEqualTo: currency)
          .orderBy('price.amount')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('최저가 게시글 조회 중 오류 발생: $e');
      return [];
    }
  }
}
