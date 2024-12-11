import 'package:dio/dio.dart';
import 'package:flutter_market_app/data/model/file_model.dart';
import 'package:flutter_market_app/data/repository/base_remote_repository.dart';

class FileRepository extends BaseRemoteRepository {
  //
  Future<FileModel?> upload({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final body = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    final response = await client.post(
      '/api/file/upload',
      data: body,
    );

    if (response.statusCode == 201) {
      final content = response.data['content'];
      return FileModel.fromJson(content);
    }

    return null;
  }
}
