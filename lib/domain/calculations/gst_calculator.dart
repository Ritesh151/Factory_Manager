/// GST calculation (client-side). CGST = SGST = half of GST for intra-state.
class GstCalculator {
  GstCalculator._();

  static GstBreakdown calculate(double amount, int gstRate) {
    final gstAmount = (amount * gstRate) / 100;
    final cgst = gstAmount / 2;
    final sgst = gstAmount / 2;
    final total = amount + gstAmount;
    return GstBreakdown(
      baseAmount: amount,
      cgst: cgst,
      sgst: sgst,
      igst: gstAmount,
      totalAmount: total,
    );
  }

  static double lineAmount(double quantity, double rate) => quantity * rate;
  static double lineGst(double amount, int gstRate) =>
      (amount * gstRate) / 100;
}

class GstBreakdown {
  const GstBreakdown({
    required this.baseAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalAmount,
  });
  final double baseAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalAmount;
}
