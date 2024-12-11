import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/image_picker_helper.dart';
import 'package:flutter_market_app/data/model/product.dart';
import 'package:flutter_market_app/ui/pages/product_write/product_write_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductWritePictureArea extends StatelessWidget {
  ProductWritePictureArea(this.product);
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(productWriteViewModel(product));
      final vm = ref.read(productWriteViewModel(product).notifier);

      final images = state.imageFiles.map((e) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                e.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList();

      return SizedBox(
        height: 60,
        width: double.infinity,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...images,
            GestureDetector(
              onTap: () async {
                final file = await ImagePickerHelper.pickImage();
                if (file != null) {
                  vm.uploadImage(
                    filename: file.filename,
                    mimeType: file.mimeType,
                    bytes: file.bytes,
                  );
                }
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      ),
                      Text(
                        '${state.imageFiles.length}/10',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
