import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/utils/gst_utils.dart';
import '../../../../core/services/pdf_service.dart';
import '../../providers/gst_invoice_provider.dart';
import '../../models/invoice_model.dart';
import 'package:printing/printing.dart';

class CreateInvoicePage extends ConsumerStatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  ConsumerState<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends ConsumerState<CreateInvoicePage> {
  final _customerNameCtrl = TextEditingController();
  final _customerGSTCtrl = TextEditingController();
  final _customerAddrCtrl = TextEditingController();
  final _transportNameCtrl = TextEditingController();
  final _vehicleNoCtrl = TextEditingController();
  final _deliveryAtCtrl = TextEditingController();
  final _transportChargesCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerGSTCtrl.dispose();
    _customerAddrCtrl.dispose();
    _transportNameCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _deliveryAtCtrl.dispose();
    _transportChargesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gstInvoiceProvider);
    final notifier = ref.read(gstInvoiceProvider.notifier);
    final invoice = state.invoice;

    return Scaffold(
      backgroundColor: ModernTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context, invoice),
            const SizedBox(height: ModernTheme.xl),
            
            // ── Company Info (Static) ──────────────────────────────────
            _buildCompanyCard(),
            const SizedBox(height: ModernTheme.lg),

            // ── Invoice & Transport Details ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTransportCard(notifier)),
                const SizedBox(width: ModernTheme.lg),
                Expanded(child: _buildCustomerCard(notifier)),
              ],
            ),
            const SizedBox(height: ModernTheme.lg),

            // ── Product Table ──────────────────────────────────────────
            _buildItemsCard(notifier, invoice),
            const SizedBox(height: ModernTheme.lg),

            // ── Summary & Totals ───────────────────────────────────────
            _buildSummaryCard(notifier, invoice),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, InvoiceModel invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create GST Invoice', style: ModernTheme.headingLarge),
            Text('SIDDHIVINAYAK ENTERPRISE', style: ModernTheme.bodyLarge.copyWith(color: ModernTheme.textSecondary)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final pdfData = await PDFService.generateGSTInvoice(invoice);
                await Printing.layoutPdf(onLayout: (format) => pdfData);
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Preview PDF'),
              style: ModernTheme.outlinedButtonStyle,
            ),
            const SizedBox(width: ModernTheme.md),
            ElevatedButton.icon(
              onPressed: () => ref.read(gstInvoiceProvider.notifier).saveInvoice(),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Generate & Save'),
              style: ModernTheme.elevatedButtonStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: ModernTheme.accent,
            radius: 24,
            child: Icon(Icons.business_rounded, color: ModernTheme.primary),
          ),
          const SizedBox(width: ModernTheme.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(InvoiceModel.companyNameConst, style: ModernTheme.headingSmall),
                Text(InvoiceModel.companyAddressConst, style: ModernTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('GSTIN: ${InvoiceModel.companyGSTINConst}', style: ModernTheme.labelSmall),
              Text('PAN: ${InvoiceModel.companyPANConst}', style: ModernTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(GSTInvoiceNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transport & Delivery', style: ModernTheme.headingSmall),
          const SizedBox(height: ModernTheme.md),
          _inputField('Transport Name', _transportNameCtrl, (v) => notifier.updateHeader(transportName: v)),
          const SizedBox(height: ModernTheme.md),
          Row(
            children: [
              Expanded(child: _inputField('Vehicle No', _vehicleNoCtrl, (v) => notifier.updateHeader(vehicleNo: v))),
              const SizedBox(width: ModernTheme.md),
              Expanded(child: _inputField('Delivery At', _deliveryAtCtrl, (v) => notifier.updateHeader(deliveryAt: v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(GSTInvoiceNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Details', style: ModernTheme.headingSmall),
          const SizedBox(height: ModernTheme.md),
          _inputField('Customer Name', _customerNameCtrl, (v) => notifier.updateHeader(customerName: v)),
          const SizedBox(height: ModernTheme.md),
          _inputField('GST Number', _customerGSTCtrl, (v) => notifier.updateHeader(customerGSTNo: v)),
          const SizedBox(height: ModernTheme.md),
          _inputField('Address', _customerAddrCtrl, (v) => notifier.updateHeader(customerAddress: v)),
        ],
      ),
    );
  }

  Widget _buildItemsCard(GSTInvoiceNotifier notifier, InvoiceModel invoice) {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line Items', style: ModernTheme.headingSmall),
              TextButton.icon(
                onPressed: notifier.addItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product'),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.md),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(50),
              1: FlexColumnWidth(3),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(100),
              5: FixedColumnWidth(120),
              6: FixedColumnWidth(40),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ModernTheme.divider))),
                children: ['#', 'Product Description', 'HSN', 'Qty', 'Rate', 'Amount', '']
                    .map((h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(h, style: ModernTheme.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
              ...invoice.items.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return TableRow(
                  children: [
                    Text('${item.srNo}', style: ModernTheme.bodyMedium),
                    _tableInput(item.description, (v) => notifier.updateItem(idx, description: v)),
                    _tableInput(item.hsnCode, (v) => notifier.updateItem(idx, hsn: v)),
                    _tableInput('${item.qty}', (v) => notifier.updateItem(idx, qty: double.tryParse(v) ?? 0), isNum: true),
                    _tableInput('${item.rate}', (v) => notifier.updateItem(idx, rate: double.tryParse(v) ?? 0), isNum: true),
                    Text(GSTUtils.formatCurrency(item.amount), style: ModernTheme.labelMedium),
                    IconButton(onPressed: () => notifier.removeItem(idx), icon: const Icon(Icons.delete_outline, size: 18, color: ModernTheme.error)),
                  ],
                );
              }),
            ],
          ),
          if (invoice.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text('No items added yet. Click "Add Product" to start.', style: ModernTheme.bodyMedium.copyWith(color: ModernTheme.textMuted)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(GSTInvoiceNotifier notifier, InvoiceModel invoice) {
    bool isIntra = GSTUtils.isIntrastate(invoice.customerState);
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputField('Transport / Other Charges', _transportChargesCtrl, (v) => notifier.updateHeader(transportCharges: double.tryParse(v) ?? 0), isNum: true),
                const SizedBox(height: ModernTheme.xl),
                Text('Total in Words:', style: ModernTheme.labelSmall),
                const SizedBox(height: 4),
                Text(invoice.totalInWords, style: ModernTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: ModernTheme.primary)),
              ],
            ),
          ),
          const SizedBox(width: ModernTheme.xl),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _summaryRow('Subtotal', GSTUtils.formatCurrency(invoice.subtotal)),
                if (isIntra) ...[
                  _summaryRow('CGST (9%)', GSTUtils.formatCurrency(invoice.cgstAmount)),
                  _summaryRow('SGST (9%)', GSTUtils.formatCurrency(invoice.sgstAmount)),
                ] else ...[
                  _summaryRow('IGST (18%)', GSTUtils.formatCurrency(invoice.igstAmount)),
                ],
                _summaryRow('Transport', GSTUtils.formatCurrency(invoice.transportCharges)),
                _summaryRow('Round Off', GSTUtils.formatCurrency(invoice.roundOff)),
                const Divider(height: 24),
                _summaryRow('Grand Total', GSTUtils.formatCurrency(invoice.grandTotal), isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? ModernTheme.labelMedium.copyWith(fontWeight: FontWeight.bold) : ModernTheme.bodyMedium),
          Text(value, style: isBold ? ModernTheme.headingSmall.copyWith(color: ModernTheme.primary) : ModernTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, Function(String) onChanged, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ModernTheme.labelSmall),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          style: ModernTheme.bodyMedium,
          decoration: ModernTheme.inputDecoration(label).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ],
    );
  }

  Widget _tableInput(String initial, Function(String) onChanged, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextFormField(
        initialValue: initial == '0' || initial == '0.0' ? '' : initial,
        onChanged: onChanged,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: ModernTheme.bodyMedium,
        decoration: const InputDecoration(
          isDense: true,
          border: UnderlineInputBorder(borderSide: BorderSide(color: ModernTheme.divider)),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: ModernTheme.surface,
      borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
      border: Border.all(color: ModernTheme.border),
      boxShadow: ModernTheme.cardShadow,
    );
  }
}
