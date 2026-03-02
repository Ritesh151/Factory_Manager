import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/invoice_firestore_datasource.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';

/// Firestore instance provider
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

/// Firebase Storage provider
final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);

/// Invoice datasource provider
final invoiceFirestoreDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return InvoiceFirestoreDataSource(firestore, storage);
});

/// Invoice repository provider (dependency injection)
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dataSource = ref.watch(invoiceFirestoreDataSourceProvider);
  return InvoiceRepositoryImpl(dataSource);
});

/// Real-time stream of all invoices
/// UI auto-updates when Firestore data changes
final allInvoicesStreamProvider = StreamProvider<List<InvoiceEntity>>((ref) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getAllInvoicesStream();
});

/// Real-time stream of invoices by status
/// Parameters: 'draft', 'sent', 'paid', 'overdue'
final invoicesByStatusStreamProvider = StreamProvider.family<
    List<InvoiceEntity>,
    String>((ref, status) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoicesByStatusStream(status);
});

/// Real-time stream of customer invoices
final customerInvoicesStreamProvider = StreamProvider.family<
    List<InvoiceEntity>,
    String>((ref, customerId) {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getCustomerInvoicesStream(customerId);
});

/// Get invoices for date range
final invoicesByDateRangeProvider = FutureProvider.family<
    List<InvoiceEntity>,
    ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoicesByDateRange(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Get invoice by ID
final invoiceByIdProvider =
    FutureProvider.family<InvoiceEntity, String>((ref, id) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoiceById(id);
});

/// Search invoices
final searchInvoicesProvider =
    FutureProvider.family<List<InvoiceEntity>, String>((ref, query) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.searchInvoices(query);
});

/// Get next invoice number
final nextInvoiceNumberProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.generateInvoiceNumber();
});

/// Invoice editing state
final invoiceEditSetProvider = StateProvider<InvoiceEntity?>((ref) => null);

/// Invoice loading state
final invoiceLoadingProvider = StateProvider<bool>((ref) => false);

/// Invoice error state
final invoiceErrorProvider = StateProvider<String?>((ref) => null);

/// Invoice PDF generation state
final invoicePdfGeneratingProvider = StateProvider<bool>((ref) => false);
