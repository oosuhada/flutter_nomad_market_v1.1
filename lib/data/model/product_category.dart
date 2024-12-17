class CategoryConstants {
  static const List<Map<String, String>> categories = [
    {"id": "all", "category": "전체"},
    {"id": "electronics", "category": "전자기기 및 가전"},
    {"id": "fashion", "category": "패션 및 액세서리"},
    {"id": "luxury", "category": "명품 및 럭셔리"},
    {"id": "crafts", "category": "공예 및 수공예품"},
    {"id": "culture", "category": "문화 및 엔터테인먼트"},
    {"id": "home", "category": "홈 및 리빙"},
    {"id": "beauty", "category": "뷰티 및 퍼스널 케어"},
    {"id": "food", "category": "식품 및 음료"},
    {"id": "kids", "category": "키즈 및 베이비"},
    {"id": "sports", "category": "스포츠 및 아웃도어"},
    {"id": "pets", "category": "반려동물 용품"},
    {"id": "health", "category": "건강 및 웰빙"},
    {"id": "auto", "category": "자동차 및 오토바이 액세서리"},
    {"id": "service", "category": "서비스"},
    {"id": "others", "category": "기타"},
    {"id": "request", "category": "구매요청"},
  ];
}

class ProductCategory {
  String id;
  String category;
  ProductCategory({
    required this.id,
    required this.category,
  });

  ProductCategory.fromJson(Map<String, dynamic> map)
      : this(
          id: map['id'],
          category: map['category'],
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
    };
  }
}
