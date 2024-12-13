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
  final bool isRequesting;
  final Product? product;

  ProductWritePage({required this.isRequesting, this.product});

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

  String _tradeMethod = '';
  bool _isPriceNegotiable = false;
  bool _isSellButtonActive = false;
  bool _isShareButtonActive = false;
  bool _isRequestButtonActive = false;
  bool _isDeliveryButtonActive = false;

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isRequesting ? '물품 의뢰하기' : '내 물건 판매'),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              ProductWritePictureArea(widget.product),
              SizedBox(height: 20),
              ProductCategoryBox(widget.product),
              SizedBox(height: 20),
              Text('거래 방식', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: widget.isRequesting
                    ? [
                        _buildTradeMethodButton('구매요청', Icons.shopping_cart,
                            _isRequestButtonActive),
                        _buildTradeMethodButton('전달요청', Icons.local_shipping,
                            _isDeliveryButtonActive),
                      ]
                    : [
                        _buildTradeMethodButton(
                            '판매하기', Icons.sell, _isSellButtonActive),
                        _buildTradeMethodButton(
                            '나눔하기', Icons.card_giftcard, _isShareButtonActive),
                      ],
              ),
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
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _isPriceNegotiable,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPriceNegotiable = value ?? false;
                      });
                    },
                  ),
                  Text('가격 제안 받기'),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '내용을 입력해주세요',
                ),
                validator: ValidatorUtil.validatorContent,
              ),
              SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {},
                  child: Text('작성 완료'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeMethodButton(String label, IconData icon, bool isActive) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _tradeMethod = label;
            _isSellButtonActive = label == '판매하기';
            _isShareButtonActive = label == '나눔하기';
            _isRequestButtonActive = label == '구매요청';
            _isDeliveryButtonActive = label == '전달요청';
          });
        },
        icon: Icon(
          icon,
          color: isActive
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
          elevation: isActive ? 2 : 0,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minimumSize: Size(0, 0),
        ),
      ),
    );
  }
}
