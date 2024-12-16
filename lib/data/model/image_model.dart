import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String url; // Firebase Storage URL
  final String? thumbnail; // 썸네일 URL (옵션)
  final DateTime uploadedAt;

  ImageModel({
    required this.url,
    this.thumbnail,
    required this.uploadedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'],
      thumbnail: json['thumbnail'],
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail': thumbnail,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
