import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/invoice_model.dart';

class GSTInvoiceRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'gst_invoices';

  GSTInvoiceRepository(this._firestore);

  Future<void> saveInvoice(InvoiceModel invoice) async {
    final docRef = _firestore.collection(_collection).doc(invoice.id.isEmpty ? null : invoice.id);
    final updatedInvoice = invoice.copyWith(id: docRef.id);
    await docRef.set(updatedInvoice.toMap());
  }

  Stream<List<InvoiceModel>> getInvoices() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data())).toList());
  }

  Future<void> deleteInvoice(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
