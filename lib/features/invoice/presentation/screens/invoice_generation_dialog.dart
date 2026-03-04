import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/invoice_provider.dart';

/// Invoice Generation Form Dialog
/// Used in Sales and Purchase modules to generate professional invoices
class InvoiceGenerationDialog extends ConsumerWidget {
  final String transactionType; // 'sale' or 'purchase'
  final VoidCallback onInvoiceGenerated;

  const InvoiceGenerationDialog({
    super.key,
    required this.transactionType,
    required this.onInvoiceGenerated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(invoiceGenerationProvider).isLoading;
    final calculations = ref.watch(invoiceCalculationsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxHeight: 900),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundCream,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generate ${transactionType == 'sale' ? 'Sales' : 'Purchase'} Invoice',
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Form Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FormField(
                    label: 'Bill No',
                    provider: invoiceBillNoProvider,
                    hintText: 'e.g., BL001',
                  ),
                  _FormField(
                    label: 'Customer/Vendor Name',
                    provider: invoiceCustomerNameProvider,
                    hintText: 'Full name',
                  ),
                  _FormField(
                    label: 'Customer Address',
                    provider: invoiceCustomerAddressProvider,
                    hintText: 'Complete address',
                  ),
                  _FormField(
                    label: 'GST Number',
                    provider: invoiceCustomerGstProvider,
                    hintText: '27AABCT1234H1Z0',
                  ),
                  _FormField(
                    label: 'Product Name',
                    provider: invoiceProductNameProvider,
                    hintText: 'Product name',
                  ),
                  _FormField(
                    label: 'Quantity',
                    provider: invoiceQuantityProvider,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    label: 'Unit Price',
                    provider: invoiceUnitPriceProvider,
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    label: 'GST Rate (%)',
                    provider: invoiceGstRateProvider,
                    hintText: '18',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Full width fields
              _FormField(
                label: 'Product Description',
                provider: invoiceProductDescriptionProvider,
                hintText: 'Describe the product...',
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Additional fields row
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Transport Charges',
                      provider: invoiceTransportChargesProvider,
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FormField(
                      label: 'Payment Method',
                      provider: invoicePaymentMethodProvider,
                      hintText: 'cash',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _FormField(
                label: 'Notes',
                provider: invoiceNotesProvider,
                hintText: 'Add any notes...',
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '₹${calculations.subtotal.toStringAsFixed(2)}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GST (@${ref.watch(invoiceGstRateProvider)}%)',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '₹${calculations.gstAmount.toStringAsFixed(2)}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transport',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '₹${(double.tryParse(ref.watch(invoiceTransportChargesProvider)) ?? 0).toStringAsFixed(2)}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '₹${calculations.grandTotal.toStringAsFixed(2)}',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _generateInvoice(
                                context,
                                ref,
                              ),
                      icon: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.onPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.file_download_rounded),
                      label: Text(isLoading ? 'Generating...' : 'Generate Invoice'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateInvoice(BuildContext context, WidgetRef ref) async {
    final billNo = ref.read(invoiceBillNoProvider);
    final customerName = ref.read(invoiceCustomerNameProvider);
    final customerAddress = ref.read(invoiceCustomerAddressProvider);
    final customerGst = ref.read(invoiceCustomerGstProvider);
    final productName = ref.read(invoiceProductNameProvider);
    final productDescription = ref.read(invoiceProductDescriptionProvider);
    final quantity = double.tryParse(ref.read(invoiceQuantityProvider)) ?? 0;
    final unitPrice = double.tryParse(ref.read(invoiceUnitPriceProvider)) ?? 0;
    final gstRate = double.tryParse(ref.read(invoiceGstRateProvider)) ?? 18;
    final transportCharges =
        double.tryParse(ref.read(invoiceTransportChargesProvider)) ?? 0;
    final paymentMethod = ref.read(invoicePaymentMethodProvider);
    final notes = ref.read(invoiceNotesProvider);

    if (billNo.isEmpty ||
        customerName.isEmpty ||
        productName.isEmpty ||
        quantity <= 0 ||
        unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(invoiceGenerationProvider.notifier).generateInvoice(
      billNo: billNo,
      customerVendorName: customerName,
      customerVendorAddress: customerAddress,
      customerVendorGst: customerGst,
      productName: productName,
      productDescription: productDescription,
      quantity: quantity,
      unitPrice: unitPrice,
      gstRate: gstRate,
      transportCharges: transportCharges,
      transactionType: transactionType,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    onInvoiceGenerated();
    if (!context.mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice generated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Reusable form field widget
class _FormField extends ConsumerWidget {
  final String label;
  final StateProvider<String> provider;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.provider,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            ref.read(provider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceGlass,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
