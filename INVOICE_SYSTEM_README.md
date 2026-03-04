# Invoice Generation System

A complete Flutter invoice generation system with template-based PDF generation, built with clean architecture and modern ERP UI design.

## Features

- ✅ **Modern ERP UI** - Glassmorphism design with professional aesthetics
- ✅ **Template-based System** - HTML templates for professional invoices
- ✅ **PDF Generation** - Automatic PDF creation with preview and print support
- ✅ **Dynamic Product Rows** - Add/remove items with real-time calculations
- ✅ **Tax Support** - Configurable tax rates with automatic calculations
- ✅ **Currency Formatting** - Professional currency display
- ✅ **State Management** - Riverpod for reactive state management
- ✅ **Navigation** - GoRouter for seamless navigation
- ✅ **Responsive Design** - Works on desktop, tablet, and mobile

## Architecture

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   └── utils/
│       └── currency_formatter.dart
├── features/
│   └── invoice/
│       ├── models/
│       │   ├── invoice_model.dart
│       │   └── invoice_item_model.dart
│       ├── providers/
│       │   └── invoice_provider.dart
│       ├── services/
│       │   ├── invoice_pdf_service.dart
│       │   └── invoice_template_service.dart
│       └── ui/
│           ├── screens/
│           │   ├── create_invoice_page.dart
│           │   └── invoice_preview_page.dart
│           └── widgets/
│               ├── invoice_item_row.dart
│               └── invoice_summary_card.dart
├── routes/
│   └── app_routes.dart
└── assets/
    └── templates/
        └── invoice_template.html
```

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the Application

```bash
flutter run
```

### 3. Access the Invoice System

1. Launch the app
2. Navigate to **Invoices** in the sidebar
3. Click **Create Invoice** to start a new invoice
4. Fill in customer and company details
5. Add products/services
6. Preview and generate PDF

## Usage Guide

### Creating an Invoice

1. **Customer Information**
   - Enter customer name (required)
   - Add email and address (optional)

2. **Company Information**
   - Fill in your company details
   - Add company email and phone

3. **Invoice Details**
   - Auto-generated invoice number (or customize)
   - Set invoice date and due date

4. **Add Items**
   - Click "Add Item" to add products/services
   - Enter product name and description
   - Set quantity and price
   - Automatic total calculation

5. **Tax Configuration**
   - Set tax rate (0-100%)
   - Automatic tax calculation

6. **Generate PDF**
   - Preview invoice before generating
   - Save PDF to device
   - Print or share invoice

### Features

- **Real-time Calculations**: All totals update automatically
- **Professional Templates**: Clean, modern invoice design
- **PDF Export**: High-quality PDF generation
- **Print Support**: Direct printing from app
- **Share Functionality**: Share invoices via email/messaging
- **Data Validation**: Ensures all required fields are filled
- **Responsive UI**: Works on all screen sizes

## Template System

The invoice system uses HTML templates with placeholder replacement:

```html
{{company_name}}      // Your company name
{{customer_name}}     // Customer name
{{invoice_no}}        // Invoice number
{{date}}              // Invoice date
{{items}}             // Product items table
{{subtotal}}          // Subtotal amount
{{tax_amount}}        // Tax amount
{{total}}             // Grand total
```

## State Management

Uses Riverpod for reactive state management:

- **InvoiceProvider**: Manages invoice state
- **InvoiceItemsProvider**: Manages product items
- **InvoiceTotalsProvider**: Calculates totals
- **CanGenerateInvoiceProvider**: Validation provider

## Services

- **InvoicePdfService**: PDF generation and management
- **InvoiceTemplateService**: HTML template processing
- **CurrencyFormatter**: Currency formatting utilities

## Dependencies

Key dependencies used:

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `pdf`: PDF generation
- `printing`: Print and preview functionality
- `path_provider`: File system access
- `intl`: Internationalization and formatting
- `uuid`: Unique ID generation
- `flutter_animate`: UI animations

## File Structure

### Models
- `InvoiceModel`: Main invoice entity
- `InvoiceItemModel`: Individual line items

### Providers
- `InvoiceNotifier`: State management for invoices
- Various computed providers for totals and validation

### Services
- `InvoicePdfService`: PDF operations
- `InvoiceTemplateService`: Template processing

### UI Components
- `CreateInvoicePage`: Invoice creation interface
- `InvoicePreviewPage`: PDF preview interface
- `InvoiceItemRow`: Individual item widget
- `InvoiceSummaryCard`: Totals display widget

## Customization

### Branding
Update company colors and branding in:
- `lib/core/theme/app_colors.dart`
- `assets/templates/invoice_template.html`

### Template Modifications
Edit the HTML template to customize:
- Company logo placement
- Layout and styling
- Additional fields
- Footer information

### Tax Calculations
Modify tax logic in:
- `lib/features/invoice/providers/invoice_provider.dart`

## Troubleshooting

### Common Issues

1. **PDF Generation Fails**
   - Ensure all required fields are filled
   - Check internet connection for template loading
   - Verify file permissions

2. **Navigation Issues**
   - Check route definitions in `app_routes.dart`
   - Ensure GoRouter is properly configured

3. **State Not Updating**
   - Verify Riverpod providers are properly initialized
   - Check widget rebuilds with `ref.watch()`

### Debug Mode

Enable debug logging by setting:
```dart
debugPrint('Invoice Debug: $message');
```

## Production Deployment

### Build Commands

```bash
# Release build
flutter build apk --release
flutter build web --release
flutter build windows --release
```

### Considerations

- Test PDF generation on target platforms
- Verify file permissions for PDF saving
- Ensure template assets are included in build
- Test print functionality on various devices

## Support

For issues and feature requests, check the following:

1. Verify all dependencies are up to date
2. Check Flutter version compatibility
3. Review console logs for error details
4. Test with different invoice data scenarios

## License

This invoice system is part of the SmartERP project and follows the same licensing terms.
