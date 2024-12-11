import 'dart:io';

import 'package:flutter_market_app/data/repository/file_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //

  test('FileRepository : upload test', () async {
    final file = File('assets/welcome.png');
    final bytes = await file.readAsBytes();
    final fileRepository = FileRepository();

    final fileModel = await fileRepository.upload(
      bytes: bytes,
      filename: 'welcome.png',
      mimeType: 'image/png',
    );
    expect(fileModel == null, false);
    expect(fileModel!.originName, 'welcome.png');
    expect(fileModel.contentType, 'image/png');

    print(fileModel.toJson());
  });
}
