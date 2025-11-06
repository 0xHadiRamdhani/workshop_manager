import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_manager/services/barcode_service.dart';
import 'package:workshop_manager/models/product.dart';
import 'package:workshop_manager/database/database_helper.dart';

void main() {
  group('BarcodeService Tests', () {
    late BarcodeService barcodeService;
    late DatabaseHelper databaseHelper;

    setUp(() {
      barcodeService = BarcodeService();
      databaseHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should parse barcode data correctly', () {
      // Test format: "PRODUCT_NAME|PRICE|CATEGORY"
      final result = barcodeService.parseBarcodeData('Oli Motor|45000|Oli');

      expect(result, isNotNull);
      expect(result!['name'], 'Oli Motor');
      expect(result['price'], 45000.0);
      expect(result['category'], 'Oli');
    });

    test('should parse barcode data with minimal format', () {
      // Test format: "PRODUCT_NAME|PRICE"
      final result = barcodeService.parseBarcodeData('Kampas Rem|120000');

      expect(result, isNotNull);
      expect(result!['name'], 'Kampas Rem');
      expect(result['price'], 120000.0);
      expect(result['category'], 'Lainnya');
    });

    test('should return null for invalid barcode format', () {
      final result = barcodeService.parseBarcodeData('InvalidFormat');

      expect(result, isNull);
    });

    test('should return null for empty barcode', () {
      final result = barcodeService.parseBarcodeData('');

      expect(result, isNull);
    });

    test('should handle barcode with special characters', () {
      final result = barcodeService.parseBarcodeData(
        'Oli Motor 10W-40|55000|Oli',
      );

      expect(result, isNotNull);
      expect(result!['name'], 'Oli Motor 10W-40');
      expect(result['price'], 55000.0);
      expect(result['category'], 'Oli');
    });

    test('should handle decimal prices', () {
      final result = barcodeService.parseBarcodeData(
        'Filter Udara|35000.50|Mesin',
      );

      expect(result, isNotNull);
      expect(result!['name'], 'Filter Udara');
      expect(result['price'], 35000.50);
      expect(result['category'], 'Mesin');
    });

    test('should handle zero price', () {
      final result = barcodeService.parseBarcodeData('Produk Gratis|0|Lainnya');

      expect(result, isNotNull);
      expect(result!['name'], 'Produk Gratis');
      expect(result['price'], 0.0);
      expect(result['category'], 'Lainnya');
    });
  });
}
