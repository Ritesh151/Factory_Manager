import 'package:flutter_test/flutter_test.dart';
import 'package:smarterp/domain/calculations/gst_calculator.dart';

void main() {
  group('GstCalculator', () {
    test('calculate 18% GST', () {
      final r = GstCalculator.calculate(1000, 18);
      expect(r.baseAmount, 1000);
      expect(r.cgst, 90);
      expect(r.sgst, 90);
      expect(r.totalAmount, 1180);
    });
    test('calculate 5% GST', () {
      final r = GstCalculator.calculate(250, 5);
      expect(r.cgst, 6.25);
      expect(r.sgst, 6.25);
      expect(r.totalAmount, 262.5);
    });
    test('zero GST', () {
      final r = GstCalculator.calculate(500, 0);
      expect(r.cgst, 0);
      expect(r.sgst, 0);
      expect(r.totalAmount, 500);
    });
    test('lineAmount', () {
      expect(GstCalculator.lineAmount(2, 100), 200);
    });
    test('lineGst', () {
      expect(GstCalculator.lineGst(1000, 18), 180);
    });
  });
}
