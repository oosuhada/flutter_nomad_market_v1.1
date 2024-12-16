import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/file_model.dart';

enum PostStatus { selling, sold, reserved }

class Post {
  final String postId;
  final String userId;
  final String originalTitle;
  final String? translatedTitle;
  final Price price;
  final String category;
  final PostStatus status;
  final bool negotiable;
  final String originalDescription;
  final String? translatedDescription;
  final List<String> images;
  final FileModel thumbnail;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int views;
  final String userNickname;
  final String userProfileImageUrl;
  final String userHomeAddress;

  Post({
    required this.postId,
    required this.userId,
    required this.originalTitle,
    this.translatedTitle,
    required this.price,
    required this.category,
    required this.status,
    required this.negotiable,
    required this.originalDescription,
    this.translatedDescription,
    required this.images,
    required this.thumbnail, // 생성자에 추가
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.views = 0,
    required this.userNickname,
    required this.userProfileImageUrl,
    required this.userHomeAddress,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>;

    return Post(
      postId: json['postId'],
      userId: json['userId'],
      originalTitle: json['originalTitle'],
      translatedTitle: json['translatedTitle'],
      price: Price(
        amount: priceData['amount'],
        currency: priceData['currency'],
      ),
      category: json['category'],
      status: PostStatus.values.firstWhere(
        (e) => e.toString() == 'PostStatus.${json['status']}',
      ),
      negotiable: json['negotiable'],
      originalDescription: json['originalDescription'],
      translatedDescription: json['translatedDescription'],
      images: List<String>.from(json['images']),
      thumbnail: FileModel.fromJson(json['thumbnail']), // JSON 변환 추가
      location: json['location'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      userNickname: json['userNickname'],
      userProfileImageUrl: json['userProfileImageUrl'],
      userHomeAddress: json['userHomeAddress'],
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'userId': userId,
        'originalTitle': originalTitle,
        'translatedTitle': translatedTitle,
        'price': price.toJson(),
        'category': category,
        'status': status.toString().split('.').last,
        'negotiable': negotiable,
        'originalDescription': originalDescription,
        'translatedDescription': translatedDescription,
        'images': images,
        'thumbnail': thumbnail.toJson(), // JSON 변환 추가
        'location': location,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'likes': likes,
        'views': views,
        'userNickname': userNickname,
        'userProfileImageUrl': userProfileImageUrl,
        'userHomeAddress': userHomeAddress,
      };

  Post copyWith({
    String? postId,
    String? userId,
    String? originalTitle,
    String? translatedTitle,
    Price? price,
    String? category,
    PostStatus? status,
    bool? negotiable,
    String? originalDescription,
    String? translatedDescription,
    List<String>? images,
    FileModel? thumbnail, // copyWith에 추가
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? views,
    String? userNickname,
    String? userProfileImageUrl,
    String? userHomeAddress,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      originalTitle: originalTitle ?? this.originalTitle,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      price: price ?? this.price,
      category: category ?? this.category,
      status: status ?? this.status,
      negotiable: negotiable ?? this.negotiable,
      originalDescription: originalDescription ?? this.originalDescription,
      translatedDescription:
          translatedDescription ?? this.translatedDescription,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail, // copyWith 메서드에 추가
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      userNickname: userNickname ?? this.userNickname,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      userHomeAddress: userHomeAddress ?? this.userHomeAddress,
    );
  }
}

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
