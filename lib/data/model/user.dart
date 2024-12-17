import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/address.dart';

enum UserStatus { active, inactive, blocked }

enum SignInMethod { email, google }

class ProfileImageUrlHelper {
  static const String defaultProfileImageUrl = '';
  static const String storageBasePath = 'files/';

  static String normalizeStorageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return defaultProfileImageUrl;
    }

    if (url.startsWith('https://firebasestorage.googleapis.com')) {
      return url;
    }

    if (url.startsWith(storageBasePath)) {
      return url;
    }

    return '$storageBasePath$url';
  }

  // 파일 이름으로부터 Storage 경로 생성
  static String createStoragePath(String filename) {
    // 파일명에 경로가 포함되어 있는 경우 처리
    if (filename.startsWith(storageBasePath)) {
      return filename;
    }

    // 파일명에서 특수문자 및 공백 제거
    final sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\s\-.]'), '');

    // 타임스탬프를 추가하여 고유한 파일명 생성
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFilename = '${timestamp}_$sanitizedFilename';

    return '$storageBasePath$uniqueFilename';
  }
}

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
  final Address address;

  User({
    required this.userId,
    required this.email,
    this.password,
    required this.nickname,
    required String profileImageUrl,
    required this.preferences,
    required this.signInMethod,
    required this.createdAt,
    required this.lastLoginAt,
    required status,
    required this.address,
  })  : this.profileImageUrl =
            ProfileImageUrlHelper.normalizeStorageUrl(profileImageUrl),
        this.status = UserStatus.values.firstWhere(
            (e) => e.toString() == 'UserStatus.$status',
            orElse: () => UserStatus.active);

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print("User.fromJson 입력 데이터: $json");

      Map<String, dynamic> preferencesData = json['preferences'] ??
          {'language': 'ko', 'currency': 'KRW', 'homeAddress': ''};

      DateTime getDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }

      return User(
        userId: json['userId'] ?? '',
        email: json['email'] ?? '',
        password: json['password'],
        nickname: json['nickname'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
        preferences: Preferences.fromJson(preferencesData),
        signInMethod: json['signInMethod'] ?? 'email',
        createdAt: getDateTime(json['createdAt']),
        lastLoginAt: getDateTime(json['lastLoginAt']),
        status: json['status'] ?? 'active',
        address: Address.fromJson(json['address'] ??
            {'fullName': preferencesData['homeAddress'] ?? ''}),
      );
    } catch (e, stackTrace) {
      print("User.fromJson 에러: $e");
      print("스택트레이스: $stackTrace");
      rethrow;
    }
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
      'status': status.toString().split('.').last,
      'address': address.toJson(),
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
    Address? address,
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
      status: status ?? this.status.toString().split('.').last,
      address: address ?? this.address,
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
