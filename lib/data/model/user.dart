// {
//     "id": 1,
//     "username": "tester",
//     "nickname": "오상구",
//     "profileImage": {
//       "id": 1,
//       "url": "http://localhost:8080/api/file/0e78ead5-cf18-465b-8f23-c1342a26fa6d",
//       "originName": "sanggoo.jpeg",
//       "contentType": "image/jpeg",
//       "createdAt": "2024-11-12T15:43:19.017Z"
//     }
//   }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/file_model.dart';

enum UserStatus { active, inactive, blocked }

enum SignInMethod { email, google }

// user.dart
class User {
  final String userId;
  final String email;
  final String? password;
  final String nickname;
  final String profileImageUrl;
  final Preferences preferences;
  final String signInMethod;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserStatus status;

  User({
    required this.userId,
    required this.email,
    this.password,
    required this.nickname,
    required this.profileImageUrl,
    required this.preferences,
    required this.signInMethod,
    required this.createdAt,
    required this.lastLoginAt,
    required status,
  }) : this.status = UserStatus.values.firstWhere(
            (e) => e.toString() == 'UserStatus.$status',
            orElse: () => UserStatus.active);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      password: json['password'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      preferences: Preferences.fromJson(json['preferences']),
      signInMethod: json['signInMethod'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
          (e) => e.toString() == 'UserStatus.${json['status']}',
          orElse: () => UserStatus.active),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences.toJson(),
      'signInMethod': signInMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'status': status,
    };
  }

  User copyWith({
    String? userId,
    String? email,
    String? password,
    String? nickname,
    String? profileImageUrl,
    Preferences? preferences,
    String? signInMethod,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? status,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      signInMethod: signInMethod ?? this.signInMethod,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      status: status ?? this.status,
    );
  }
}

class Preferences {
  final String language;
  final String currency;
  final String homeAddress;

  Preferences({
    required this.language,
    required this.currency,
    required this.homeAddress,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      language: json['language'],
      currency: json['currency'],
      homeAddress: json['homeAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'currency': currency,
      'homeAddress': homeAddress,
    };
  }

  Preferences copyWith({
    String? language,
    String? currency,
    String? homeAddress,
  }) {
    return Preferences(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      homeAddress: homeAddress ?? this.homeAddress,
    );
  }
}

// class User {
//   int id;
//   String username;
//   String nickname;
//   FileModel profileImage;

//   User({
//     required this.id,
//     required this.username,
//     required this.nickname,
//     required this.profileImage,
//   });

//   // 1. fromJson 네임드 생성자
//   User.fromJson(Map<String, dynamic> map)
//       : this(
//           id: map['id'],
//           username: map['username'],
//           nickname: map['nickname'],
//           profileImage: FileModel.fromJson(map['profileImage']),
//         );

//   // 2. toJson 메서드
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'nickname': nickname,
//       'profileImage': profileImage.toJson(),
//     };
//   }
