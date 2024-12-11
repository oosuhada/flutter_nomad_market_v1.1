import 'package:flutter_market_app/data/repository/chat_repository.dart';
import 'package:flutter_market_app/data/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final userRepository = UserRepository();
  final chatRepository = ChatRepository();

  test('ChatRepository : list test', () async {
    final result1 = await chatRepository.list();
    expect(result1 == null, true);
    await userRepository.login(username: 'tester', password: '1111');
    final result2 = await chatRepository.list();
    expect(result2 != null, true);
    for (var e in result2!) {
      print(e.toJson());
    }
  });

  test('ChatRepository : detail test', () async {
    await userRepository.login(username: 'tester', password: '1111');
    final result = await chatRepository.detail(1);
    expect(result != null, true);

    print(result?.toJson());
  });
}
