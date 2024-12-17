import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/model/post_enums.dart';

class Price {
  final num amount;
  final String currency;

  const Price({
    required this.amount,
    required this.currency,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: json['amount'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
      };
}

class Post {
  final String postId; // 게시글 고유 식별자
  final String userId; // 작성자 ID
  final String originalTitle; // 원본 제목 (작성자 언어)
  final String? translatedTitle; // 번역된 제목 (사용자 언어)
  final Price price; // 가격 정보
  final String category; // 카테고리
  final PostType type; // 판매/구매 구분
  final PostStatus status; // 거래 상태
  final bool negotiable; // 가격 협상 가능 여부
  final String originalDescription; // 원본 설명 (작성자 언어)
  final String? translatedDescription; // 번역된 설명 (사용자 언어)
  final List<FileModel> images; // 게시글 이미지 목록
  final FileModel thumbnail; // 썸네일 이미지
  final Address address; // 거래 희망 위치 정보
  final DateTime createdAt; // 게시글 작성 시간
  final DateTime updatedAt; // 게시글 최종 수정 시간
  final int likes; // 좋아요 수
  final int views; // 조회수
  final String userNickname; // 작성자 닉네임
  final String userProfileImageUrl; // 작성자 프로필 이미지 URL
  final Address userAddress; // 작성자 주소 정보
  final String language; // 게시글 작성 언어 (예: 'ko', 'en', 'ja')

  Post({
    required this.postId,
    required this.userId,
    required this.originalTitle,
    this.translatedTitle,
    required this.price,
    required this.category,
    required this.type,
    required this.status,
    required this.negotiable,
    required this.originalDescription,
    this.translatedDescription,
    required this.images,
    required this.thumbnail,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.views = 0,
    required this.userNickname,
    required this.userProfileImageUrl,
    required this.userAddress,
    required this.language,
  });

  // 거래 상태에 따른 한글 라벨을 반환하는 getter 메서드
  String get statusLabel {
    switch (status) {
      case PostStatus.active:
        return type == PostType.selling ? "판매중" : "구매중";
      case PostStatus.completed:
        return "거래완료";
      case PostStatus.reserved:
        return "예약중";
    }
  }

  // JSON 변환 메서드
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      userId: json['userId'],
      originalTitle: json['originalTitle'],
      translatedTitle: json['translatedTitle'],
      price: Price.fromJson(json['price']),
      category: json['category'],
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${json['type']}',
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.toString() == 'PostStatus.${json['status']}',
      ),
      negotiable: json['negotiable'],
      originalDescription: json['originalDescription'],
      translatedDescription: json['translatedDescription'],
      images:
          (json['images'] as List).map((e) => FileModel.fromJson(e)).toList(),
      thumbnail: FileModel.fromJson(json['thumbnail']),
      address: Address.fromJson(json['address']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      userNickname: json['userNickname'],
      userProfileImageUrl: json['userProfileImageUrl'],
      userAddress: Address.fromJson(json['userAddress']),
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'userId': userId,
        'originalTitle': originalTitle,
        'translatedTitle': translatedTitle,
        'price': price.toJson(),
        'category': category,
        'type': type.toString().split('.').last,
        'status': status.toString().split('.').last,
        'negotiable': negotiable,
        'originalDescription': originalDescription,
        'translatedDescription': translatedDescription,
        'images': images.map((e) => e.toJson()).toList(),
        'thumbnail': thumbnail.toJson(),
        'address': address.toJson(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'likes': likes,
        'views': views,
        'userNickname': userNickname,
        'userProfileImageUrl': userProfileImageUrl,
        'userAddress': userAddress.toJson(),
        'language': language,
      };

  // 객체 복사 메서드
  Post copyWith({
    String? postId,
    String? userId,
    String? originalTitle,
    String? translatedTitle,
    Price? price,
    String? category,
    PostType? type,
    PostStatus? status,
    bool? negotiable,
    String? originalDescription,
    String? translatedDescription,
    List<FileModel>? images,
    FileModel? thumbnail,
    Address? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? views,
    String? userNickname,
    String? userProfileImageUrl,
    Address? userAddress,
    String? language,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      originalTitle: originalTitle ?? this.originalTitle,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      price: price ?? this.price,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      negotiable: negotiable ?? this.negotiable,
      originalDescription: originalDescription ?? this.originalDescription,
      translatedDescription:
          translatedDescription ?? this.translatedDescription,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      userNickname: userNickname ?? this.userNickname,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      userAddress: userAddress ?? this.userAddress,
      language: language ?? this.language,
    );
  }
}
