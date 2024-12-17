// post_summary_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';

class PostSummaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 게시글 요약 목록 조회 메서드
  Future<List<PostSummary>> getPostSummaryList({
    String? addressId, // 지역 필터
    PostStatus? status, // 거래 상태 필터
    PostType? type, // 게시글 타입 필터
    String? language, // 언어 필터
    String? currency, // 통화 필터
    int limit = 20, // 조회 개수 제한
  }) async {
    try {
      Query query = _firestore.collection('post_summaries');

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
        query = query.where('currency', isEqualTo: currency);
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
      Query query = _firestore
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
      Query query = _firestore
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

      Query query = _firestore
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
