import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/invoice_entity.dart';
import '../services/invoice_service.dart';

/// Invoice Service Provider
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  return InvoiceServiceImpl();
});

/// Invoice Generation State
class InvoiceGenerationState {
  final InvoiceEntity? invoice;
  final bool isLoading;
  final String? error;
  final bool isExporting;

  InvoiceGenerationState({
    this.invoice,
    this.isLoading = false,
    this.error,
    this.isExporting = false,
  });

  InvoiceGenerationState copyWith({
    InvoiceEntity? invoice,
    bool? isLoading,
    String? error,
    bool? isExporting,
  }) {
    return InvoiceGenerationState(
      invoice: invoice ?? this.invoice,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

/// Invoice Generation Notifier
class InvoiceGenerationNotifier extends StateNotifier<InvoiceGenerationState> {
  final InvoiceService _invoiceService;

  InvoiceGenerationNotifier(this._invoiceService)
      : super(InvoiceGenerationState());

  Future<void> generateInvoice({
    required String billNo,
    required String customerVendorName,
    required String customerVendorAddress,
    required String customerVendorGst,
    required String productName,
    required String productDescription,
    required double quantity,
    required double unitPrice,
    required double gstRate,
    required double transportCharges,
    required String transactionType,
    required String paymentMethod,
    String? notes,
    String? terms,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoice = await _invoiceService.generateInvoice(
        billNo: billNo,
        customerVendorName: customerVendorName,
        customerVendorAddress: customerVendorAddress,
        customerVendorGst: customerVendorGst,
        productName: productName,
        productDescription: productDescription,
        quantity: quantity,
        unitPrice: unitPrice,
        gstRate: gstRate,
        transportCharges: transportCharges,
        transactionType: transactionType,
        paymentMethod: paymentMethod,
        notes: notes,
        terms: terms,
      );
      state = state.copyWith(invoice: invoice, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearInvoice() {
    state = InvoiceGenerationState();
  }
}

/// Invoice Generation Provider
final invoiceGenerationProvider =
    StateNotifierProvider<InvoiceGenerationNotifier, InvoiceGenerationState>(
  (ref) {
    final service = ref.watch(invoiceServiceProvider);
    return InvoiceGenerationNotifier(service);
  },
);

/// Form State Providers for Invoice Generation
final invoiceBillNoProvider = StateProvider<String>((ref) => '');
final invoiceCustomerNameProvider = StateProvider<String>((ref) => '');
final invoiceCustomerAddressProvider = StateProvider<String>((ref) => '');
final invoiceCustomerGstProvider = StateProvider<String>((ref) => '');
final invoiceProductNameProvider = StateProvider<String>((ref) => '');
final invoiceProductDescriptionProvider = StateProvider<String>((ref) => '');
final invoiceQuantityProvider = StateProvider<String>((ref) => '');
final invoiceUnitPriceProvider = StateProvider<String>((ref) => '');
final invoiceGstRateProvider = StateProvider<String>((ref) => '18');
final invoiceTransportChargesProvider = StateProvider<String>((ref) => '');
final invoiceTransactionTypeProvider = StateProvider<String>((ref) => 'sale');
final invoicePaymentMethodProvider = StateProvider<String>((ref) => 'cash');
final invoiceNotesProvider = StateProvider<String>((ref) => '');
final invoiceTermsProvider = StateProvider<String>((ref) => '');

/// Calculated values provider
final invoiceCalculationsProvider = Provider<InvoiceCalculations>((ref) {
  final quantity = double.tryParse(ref.watch(invoiceQuantityProvider)) ?? 0;
  final unitPrice = double.tryParse(ref.watch(invoiceUnitPriceProvider)) ?? 0;
  final gstRate = double.tryParse(ref.watch(invoiceGstRateProvider)) ?? 18;
  final transportCharges =
      double.tryParse(ref.watch(invoiceTransportChargesProvider)) ?? 0;

  final service = ref.watch(invoiceServiceProvider);
  final subtotal = quantity * unitPrice;
  final gstAmount = service.calculateGstAmount(subtotal, gstRate);
  final grandTotal = service.calculateGrandTotal(subtotal, gstAmount, transportCharges);

  return InvoiceCalculations(
    subtotal: subtotal,
    gstAmount: gstAmount,
    grandTotal: grandTotal,
  );
});

class InvoiceCalculations {
  final double subtotal;
  final double gstAmount;
  final double grandTotal;

  InvoiceCalculations({
    required this.subtotal,
    required this.gstAmount,
    required this.grandTotal,
  });
}
