import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/product_category.dart';

class ProductCategoryRepository {
  final firestore = FirebaseFirestore.instance;

  Future<List<ProductCategory>?> getCategoryList() async {
    try {
      final querySnapshot =
          await firestore.collection('product_categories').get();
      return querySnapshot.docs
          .map((doc) => ProductCategory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching product categories: $e');
      return null;
    }
  }
}
