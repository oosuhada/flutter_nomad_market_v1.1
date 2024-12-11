import 'package:flutter_market_app/data/model/product_category.dart';
import 'package:flutter_market_app/data/repository/base_remote_repository.dart';

class ProductCategoryRepository extends BaseRemoteRepository {
  Future<List<ProductCategory>?> getCategoryList() async {
    final response = await client.get('/api/product/category');
    if (response.statusCode == 200) {
      final content = response.data['content'];
      return List.from(content)
          .map((e) => ProductCategory.fromJson(e))
          .toList();
    }

    return null;
  }
}
