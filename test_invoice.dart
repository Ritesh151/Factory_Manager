import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/invoice/providers/invoice_provider.dart';
import 'features/invoice/ui/screens/create_invoice_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: TestInvoiceApp(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class TestInvoiceApp extends StatelessWidget {
  const TestInvoiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CreateInvoicePage();
  }
}
