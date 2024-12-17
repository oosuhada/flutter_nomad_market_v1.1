// post_summary.dart
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';

class PostSummary {
  final String id; // 게시글 고유 식별자
  final String title; // 게시글 제목 (원본)
  final String? translatedTitle; // 번역된 제목
  final num price; // 가격
  final String currency; // 통화 단위 (KRW, USD, JPY 등)
  final String language; // 작성 언어 (ko, en, ja 등)
  final FileModel thumbnail; // 썸네일 이미지
  final PostType type; // 게시글 타입 (판매/구매)
  final PostStatus status; // 거래 상태
  final int likeCnt; // 좋아요 수
  final Address address; // 거래 장소 주소
  final DateTime updatedAt; // 최종 수정 시간
  final DateTime createdAt; // 작성 시간

  const PostSummary({
    required this.id,
    required this.title,
    this.translatedTitle,
    required this.price,
    required this.currency,
    required this.language,
    required this.thumbnail,
    required this.type,
    required this.status,
    required this.likeCnt,
    required this.address,
    required this.updatedAt,
    required this.createdAt,
  });

  // JSON 변환 생성자
  factory PostSummary.fromJson(Map<String, dynamic> json) {
    return PostSummary(
      id: json['id'],
      title: json['title'],
      translatedTitle: json['translatedTitle'],
      price: json['price'],
      currency: json['currency'],
      language: json['language'],
      thumbnail: FileModel.fromJson(json['thumbnail']),
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${json['type']}',
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.toString() == 'PostStatus.${json['status']}',
      ),
      likeCnt: json['likeCnt'],
      address: Address.fromJson(json['address']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'translatedTitle': translatedTitle,
      'price': price,
      'currency': currency,
      'language': language,
      'thumbnail': thumbnail.toJson(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'likeCnt': likeCnt,
      'address': address.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 객체 복사 메서드
  PostSummary copyWith({
    String? id,
    String? title,
    String? translatedTitle,
    num? price,
    String? currency,
    String? language,
    FileModel? thumbnail,
    PostType? type,
    PostStatus? status,
    int? likeCnt,
    Address? address,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return PostSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      thumbnail: thumbnail ?? this.thumbnail,
      type: type ?? this.type,
      status: status ?? this.status,
      likeCnt: likeCnt ?? this.likeCnt,
      address: address ?? this.address,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 거래 상태 라벨 반환 메서드
  String get statusLabel {
    switch (status) {
      case PostStatus.active:
        return type == PostType.selling ? "판매중" : "구매중";
      case PostStatus.reserved:
        return "예약중";
      case PostStatus.completed:
        return "거래완료";
    }
  }
}
