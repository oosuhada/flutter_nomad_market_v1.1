import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_market_app/core/validator_util.dart';
import 'package:flutter_market_app/data/model/product.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_detail/product_detail_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_view_model.dart';
import 'package:flutter_market_app/ui/pages/product_write/widgets/product_category_box.dart';
import 'package:flutter_market_app/ui/pages/product_write/widgets/product_write_picture_area.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductWritePage extends StatefulWidget {
  ProductWritePage(this.product);

  Product? product;

  @override
  State<ProductWritePage> createState() => _ProductWritePageState();
}

class _ProductWritePageState extends State<ProductWritePage> {
  late final titleController =
      TextEditingController(text: widget.product?.title ?? '');
  late final priceController =
      TextEditingController(text: widget.product?.price.toString() ?? '');
  late final contentController =
      TextEditingController(text: widget.product?.content ?? '');
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void onWriteDone(WidgetRef ref) async {
    if (formKey.currentState?.validate() ?? false) {
      final vm = ref.read(productWriteViewModel(widget.product).notifier);
      final result = await vm.upload(
        title: titleController.text,
        content: contentController.text,
        price: int.parse(priceController.text),
      );
      if (result == true) {
        // 홈탭 업데이트
        ref.read(homeTabViewModel.notifier).fetchProducts();
        // 수정이면 디테일 페이지 업데이트!
        if (widget.product != null) {
          ref
              .read(productDetailViewModel(widget.product!.id).notifier)
              .fetchDetail();
        }

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              ProductWritePictureArea(widget.product),
              SizedBox(height: 20),
              ProductCategoryBox(widget.product),
              SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '상품명을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorTitle,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: '가격을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorPrice,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: '내용을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorContent,
              ),
              SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    onWriteDone(ref);
                  },
                  child: Text('작성 완료'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
