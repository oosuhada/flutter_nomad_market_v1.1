// {
//     "id": 4,
//     "url": "http://192.168.219.102:8080/api/file/eef05856-9d73-4ee6-b880-ef5bdfe8e457",
//     "originName": "welcome.png",
//     "contentType": "image/png",
//     "createdAt": "2024-11-12T15:08:02.558+00:00"
//   }

class FileModel {
  int id;
  String url;
  String originName;
  String contentType;
  DateTime createdAt;

  FileModel({
    required this.id,
    required this.url,
    required this.originName,
    required this.contentType,
    required this.createdAt,
  });

  // fromJson 생성자
  FileModel.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          url: map['url'],
          originName: map['originName'],
          contentType: map['contentType'],
          createdAt: DateTime.parse(map['createdAt']),
        );

  // toJson 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'originName': originName,
      'contentType': contentType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
