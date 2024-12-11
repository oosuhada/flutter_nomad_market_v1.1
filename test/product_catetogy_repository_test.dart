import 'package:flutter_market_app/data/repository/product_category_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProductCategoryRepository : getCategory list', () async {
    final userRepository = UserRepository();
    final productCategoryRepository = ProductCategoryRepository();
    final result1 = await productCategoryRepository.getCategoryList();
    expect(result1 == null, true);

    await userRepository.login(username: 'tester', password: '1111');

    final result2 = await productCategoryRepository.getCategoryList();
    expect(result2 == null, false);
    for (var e in result2!) {
      print(e.toJson());
    }
  });
}
