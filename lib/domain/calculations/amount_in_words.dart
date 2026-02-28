/// Converts number to Indian amount in words (simplified).
String amountInWords(double amount) {
  if (amount <= 0) return 'Zero only';
  final rupees = amount.floor();
  final paise = ((amount - rupees) * 100).round();
  final r = _toWords(rupees);
  final p = paise > 0 ? ' and $paise/100' : '';
  return 'Rupees $r$p only';
}

const _ones = [
  '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
  'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
  'Seventeen', 'Eighteen', 'Nineteen'
];
const _tens = [
  '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty',
  'Ninety'
];

String _toWords(int n) {
  if (n == 0) return 'Zero';
  if (n < 20) return _ones[n];
  if (n < 100) return '${_tens[n ~/ 10]} ${_ones[n % 10]}'.trim();
  if (n < 1000) {
    final h = n ~/ 100;
    final rest = n % 100;
    return '${_ones[h]} Hundred ${_toWords(rest)}'.trim();
  }
  if (n < 100000) {
    final th = n ~/ 1000;
    final rest = n % 1000;
    return '${_toWords(th)} Thousand ${_toWords(rest)}'.trim();
  }
  if (n < 10000000) {
    final l = n ~/ 100000;
    final rest = n % 100000;
    return '${_toWords(l)} Lakh ${_toWords(rest)}'.trim();
  }
  final cr = n ~/ 10000000;
  final rest = n % 10000000;
  return '${_toWords(cr)} Crore ${_toWords(rest)}'.trim();
}
