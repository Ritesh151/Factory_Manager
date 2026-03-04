import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../data/repositories/gst_invoice_repository.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/gst_utils.dart';

// Repository Provider
final gstInvoiceRepositoryProvider = Provider((ref) {
  final firestore = FirebaseService().firestore;
  return GSTInvoiceRepository(firestore);
});

// All Invoices Stream Provider
final allInvoicesProvider = StreamProvider<List<InvoiceModel>>((ref) {
  return ref.watch(gstInvoiceRepositoryProvider).getInvoices();
});

class GSTInvoiceState {
  final InvoiceModel invoice;
  final bool isSaving;
  final String? error;

  GSTInvoiceState({
    required this.invoice,
    this.isSaving = false,
    this.error,
  });

  GSTInvoiceState copyWith({
    InvoiceModel? invoice,
    bool? isSaving,
    String? error,
  }) {
    return GSTInvoiceState(
      invoice: invoice ?? this.invoice,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }
}

class GSTInvoiceNotifier extends StateNotifier<GSTInvoiceState> {
  final GSTInvoiceRepository _repository;

  GSTInvoiceNotifier(this._repository) : super(GSTInvoiceState(invoice: InvoiceModel.empty()));

  void updateHeader({
    String? transportName,
    String? vehicleNo,
    String? deliveryAt,
    String? customerName,
    String? customerGSTNo,
    String? customerAddress,
    String? customerState,
    double? transportCharges,
    DateTime? date,
  }) {
    final updatedInvoice = state.invoice.copyWith(
      transportName: transportName,
      vehicleNo: vehicleNo,
      deliveryAt: deliveryAt,
      customerName: customerName,
      customerGSTNo: customerGSTNo,
      customerAddress: customerAddress,
      customerState: customerState,
      transportCharges: transportCharges,
      date: date,
    );
    state = state.copyWith(invoice: _calculateTotals(updatedInvoice));
  }

  void addItem() {
    final newItem = LineItem(
      srNo: state.invoice.items.length + 1,
      description: '',
      hsnCode: '',
      qty: 0,
      rate: 0,
      amount: 0,
    );
    final updatedItems = [...state.invoice.items, newItem];
    state = state.copyWith(invoice: _calculateTotals(state.invoice.copyWith(items: updatedItems)));
  }

  void updateItem(int index, {String? description, String? hsn, double? qty, double? rate}) {
    if (index >= 0 && index < state.invoice.items.length) {
      final items = [...state.invoice.items];
      final item = items[index];
      
      final updatedQty = qty ?? item.qty;
      final updatedRate = rate ?? item.rate;
      
      items[index] = item.copyWith(
        description: description,
        hsnCode: hsn,
        qty: updatedQty,
        rate: updatedRate,
        amount: updatedQty * updatedRate,
      );
      
      state = state.copyWith(invoice: _calculateTotals(state.invoice.copyWith(items: items)));
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < state.invoice.items.length) {
      final items = state.invoice.items.asMap().entries
          .where((e) => e.key != index)
          .map((e) => e.value.copyWith(srNo: 0)) 
          .toList();
      
      final reindexed = items.asMap().entries.map((e) => e.value.copyWith(srNo: e.key + 1)).toList();
      
      state = state.copyWith(invoice: _calculateTotals(state.invoice.copyWith(items: reindexed)));
    }
  }

  InvoiceModel _calculateTotals(InvoiceModel inv) {
    double subtotal = inv.items.fold(0, (sum, item) => sum + item.amount);
    
    bool isIntra = GSTUtils.isIntrastate(inv.customerState);
    
    double cgst = 0;
    double sgst = 0;
    double igst = 0;
    
    if (isIntra) {
      cgst = subtotal * inv.cgstRate;
      sgst = subtotal * inv.sgstRate;
    } else {
      igst = subtotal * inv.igstRate;
    }
    
    double intermediateTotal = subtotal + cgst + sgst + igst + inv.transportCharges;
    double roundedTotal = intermediateTotal.roundToDouble();
    double roundOff = roundedTotal - intermediateTotal;
    
    // Auto-generate invoice number if empty
    String invNo = inv.invoiceNo;
    if (invNo.isEmpty) {
      invNo = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }

    return inv.copyWith(
      invoiceNo: invNo,
      subtotal: subtotal,
      cgstAmount: cgst,
      sgstAmount: sgst,
      igstAmount: igst,
      roundOff: roundOff,
      grandTotal: roundedTotal,
      totalInWords: GSTUtils.convertToWords(roundedTotal),
    );
  }

  Future<void> saveInvoice() async {
    if (state.invoice.customerName.isEmpty || state.invoice.items.isEmpty) {
      state = state.copyWith(error: 'Please fill in required fields and add items.');
      return;
    }

    state = state.copyWith(isSaving: true, error: null);
    try {
      final invoiceToSave = state.invoice.id.isEmpty 
          ? state.invoice.copyWith(id: const Uuid().v4()) 
          : state.invoice;
          
      await _repository.saveInvoice(invoiceToSave);
      state = state.copyWith(isSaving: false, invoice: InvoiceModel.empty());
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final gstInvoiceProvider = StateNotifierProvider<GSTInvoiceNotifier, GSTInvoiceState>((ref) {
  final repository = ref.watch(gstInvoiceRepositoryProvider);
  return GSTInvoiceNotifier(repository);
});
