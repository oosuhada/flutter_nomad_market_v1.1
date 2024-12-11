import 'package:flutter_market_app/data/repository/vworld_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final vwolrdRepo = VworldRepository();

  test('VworldRepository : findByName test', () async {
    final result = await vwolrdRepo.findByName('온천동');
    expect(result.isEmpty, false);

    final result2 = await vwolrdRepo.findByName('asd');
    expect(result2.isEmpty, true);
  });
  test('VwroldRepository : findByLatLng test', () async {
    // 35.2210076 129.0826365
    final result = await vwolrdRepo.findByLatLng(35.2210076, 129.0826365);
    print(result);
    expect(result.isEmpty, false);

    final result2 = await vwolrdRepo.findByLatLng(32.2210076, 129.0826365);
    expect(result2.isEmpty, true);
  });
}
