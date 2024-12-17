// post_summary_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';

class PostSummaryRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 상품 ID로 특정 상품 요약 정보 가져오기
  Future<PostSummary?> getProductSummary(String productId) async {
    try {
      // Firestore 인스턴스 가져오기
      final docRef =
          FirebaseFirestore.instance.collection('posts').doc(productId);

      // 문서 스냅샷 가져오기
      final snapshot = await docRef.get();

      // 데이터 확인 후 ProductSummary로 매핑
      if (snapshot.exists) {
        return PostSummary.fromJson({
          'id': snapshot.id,
          ...snapshot.data()!,
        });
      } else {
        print('상품 ID에 해당하는 데이터가 없습니다: $productId');
        return null;
      }
    } catch (e) {
      print('상품 요약 정보 가져오기 실패: $e');
      return null;
    }
  }

  // 모든 상품 요약 정보 가져오기
  Future<List<PostSummary>> getAllProducts() async {
    try {
      print('===== getAllProducts 시작 =====');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      print('Firestore 쿼리 결과: ${querySnapshot.docs.length}개 문서');

      final products = <PostSummary>[];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          print('문서 데이터 확인: ${doc.id}');
          print('데이터 내용: $data');

          // price 필드 검증
          if (data['price'] == null ||
              data['price']['amount'] == null ||
              data['price']['currency'] == null) {
            print('price 필드가 누락되었습니다: $data');
            continue; // 누락된 데이터 건너뛰기
          }

          // 필수 필드 존재 여부 확인
          final requiredFields = [
            'originalTitle',
            'price',
            'language',
            'thumbnail',
            'type',
            'status',
            'likes',
            'address',
            'updatedAt',
            'createdAt'
          ];

          final missingFields = requiredFields
              .where((field) => !data.containsKey(field))
              .toList();

          if (missingFields.isNotEmpty) {
            print('누락된 필드들: $missingFields');
            continue;
          }

          final product = PostSummary.fromJson({
            'id': doc.id,
            ...data,
          });
          products.add(product);
          print('상품 변환 성공: ${product.id}');
        } catch (e) {
          print('개별 상품 변환 실패: $e');
          continue;
        }
      }

      print('총 변환 성공: ${products.length}개 상품');
      return products;
    } catch (e, stack) {
      print('getAllProducts 실패');
      print('에러: $e');
      print('스택트레이스: $stack');
      return [];
    }
  }

  // 게시글 요약 목록 조회 메서드
  Future<List<PostSummary>> getPostSummaryList({
    String? addressId, // 지역 필터
    PostStatus? status, // 거래 상태 필터
    PostType? type, // 게시글 타입 필터
    String? language, // 언어 필터
    String? currency, // 통화 필터
    int limit = 20, // 조회 개수 제한
    DocumentSnapshot? startAfter, // 페이징 기준
    DocumentSnapshot? lastDocument, // 마지막 문서
  }) async {
    try {
      Query query = firestore.collection('post_summaries');

      // 필터 조건 적용

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

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
        query = query.where('currency', isEqualTo: currency);
      }

      // 페이징 처리
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // 최신 수정순으로 정렬
      query = query.orderBy('updatedAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => PostSummary.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('게시글 요약 목록 조회 중 오류 발생: $e');
      return [];
    }
  }

  // 특정 사용자의 게시글 요약 목록 조회
  Future<List<PostSummary>> getUserPostSummaries({
    required String userId,
    PostStatus? status,
    int limit = 20,
  }) async {
    try {
      Query query = firestore
          .collection('post_summaries')
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query =
            query.where('status', isEqualTo: status.toString().split('.').last);
      }

      query = query.orderBy('updatedAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => PostSummary.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('사용자 게시글 요약 목록 조회 중 오류 발생: $e');
      return [];
    }
  }

  // 인기 게시글 요약 목록 조회 (좋아요 순)
  Future<List<PostSummary>> getPopularPostSummaries({
    required int minLikes, // 최소 좋아요 수
    String? language, // 언어 필터
    int limit = 20, // 조회 개수 제한
  }) async {
    try {
      Query query = firestore
          .collection('post_summaries')
          .where('likeCnt', isGreaterThanOrEqualTo: minLikes);

      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }

      query = query.orderBy('likeCnt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => PostSummary.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('인기 게시글 요약 목록 조회 중 오류 발생: $e');
      return [];
    }
  }

  // 최근 게시글 요약 목록 조회
  Future<List<PostSummary>> getRecentPostSummaries({
    required Duration withinDuration, // 조회 기간
    String? language, // 언어 필터
    int limit = 20, // 조회 개수 제한
  }) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(withinDuration);

      Query query = firestore
          .collection('post_summaries')
          .where('createdAt', isGreaterThanOrEqualTo: cutoffDate);

      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => PostSummary.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('최근 게시글 요약 목록 조회 중 오류 발생: $e');
      return [];
    }
  }
}
