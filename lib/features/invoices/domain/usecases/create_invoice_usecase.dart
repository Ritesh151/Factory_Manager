import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../core/services/pdf/invoice_pdf_service.dart';
import '../../../core/error/exceptions.dart';

/// Use case for creating an invoice with PDF generation
/// This demonstrates the complete workflow:
/// 1. Create invoice in Firestore
/// 2. Generate PDF
/// 3. Upload PDF to Firebase Storage
/// 4. Save PDF URL to invoice document
class CreateInvoiceWithPdfUseCase {
  final InvoiceRepository invoiceRepository;
  final ProductRepository productRepository;

  CreateInvoiceWithPdfUseCase({
    required this.invoiceRepository,
    required this.productRepository,
  });

  /// Execute the use case
  Future<InvoiceEntity> call({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required List<({String productId, double quantity})> items,
    required String notes,
  }) async {
    try {
      // Step 1: Fetch products and validate stock
      final products = <ProductEntity>[];
      final stockUpdates = <String, int>{};

      for (final item in items) {
        final product = await productRepository.getProductById(item.productId);
        
        // Validate stock
        if (product.quantity < item.quantity) {
          throw ValidationException(
            message:
                'Insufficient stock for ${product.name}. Available: ${product.quantity}, Requested: ${item.quantity}',
          );
        }

        products.add(product);
        stockUpdates[product.id] = item.quantity.toInt();
      }

      // Step 2: Calculate invoice totals
      final invoiceItems = <InvoiceItemEntity>[];
      double subtotal = 0;
      double totalTax = 0;

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final product = products[i];

        final itemSubtotal = product.price * item.quantity;
        final itemTax = itemSubtotal * (product.gstPercentage / 100);
        final itemTotal = itemSubtotal + itemTax;

        invoiceItems.add(
          InvoiceItemEntity(
            productId: product.id,
            productName: product.name,
            quantity: item.quantity,
            unitPrice: product.price,
            taxRate: product.gstPercentage,
            total: itemTotal,
          ),
        );

        subtotal += itemSubtotal;
        totalTax += itemTax;
      }

      // Step 3: Generate invoice number
      final invoiceNumber = await invoiceRepository.generateInvoiceNumber();

      // Step 4: Create invoice document
      final invoice = InvoiceEntity(
        id: const Uuid().v4(),
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        items: invoiceItems,
        subtotal: subtotal,
        taxAmount: totalTax,
        totalAmount: subtotal + totalTax,
        status: 'draft',
        notes: notes,
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create invoice in Firestore
      final createdInvoice = await invoiceRepository.createInvoice(invoice);

      // Step 5: Generate PDF
      final pdfBytes = await InvoicePdfService.generatePdfBytes(createdInvoice);

      // Step 6: Save PDF locally
      final pdfPath =
          await InvoicePdfService.generateAndSavePdf(createdInvoice);

      // Step 7: Update invoice with PDF URL
      // In production, upload to Firebase Storage first
      // For now, we'll use local path
      await invoiceRepository.savePdfUrl(createdInvoice.id, pdfPath);

      // Step 8: Update product stock quantities
      await productRepository.updateProductStocks(stockUpdates);

      return createdInvoice;
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to create invoice: $e',
        originalException: e,
      );
    }
  }
}

/// Use case for updating invoice status
class UpdateInvoiceStatusUseCase {
  final InvoiceRepository invoiceRepository;

  UpdateInvoiceStatusUseCase({required this.invoiceRepository});

  Future<void> call({
    required String invoiceId,
    required String newStatus,
  }) async {
    try {
      // Validate status
      const validStatuses = ['draft', 'sent', 'paid', 'overdue'];
      if (!validStatuses.contains(newStatus)) {
        throw ValidationException(message: 'Invalid invoice status');
      }

      await invoiceRepository.updateInvoiceStatus(invoiceId, newStatus);
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to update invoice status: $e',
        originalException: e,
      );
    }
  }
}
