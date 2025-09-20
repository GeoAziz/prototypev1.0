import 'package:flutter_test/flutter_test.dart';
import '../lib/features/provider/models/package_deal_model.dart';

void main() {
  test('PackageDeal model serialization', () {
    final deal = PackageDeal(
      id: 'pd1',
      providerId: 'p1',
      title: 'Combo',
      description: 'Test combo',
      price: 2000.0,
      services: ['Cleaning'],
    );
    final json = deal.toJson();
    final fromJson = PackageDeal.fromJson(json);
    expect(fromJson.id, deal.id);
    expect(fromJson.title, deal.title);
  });
}
