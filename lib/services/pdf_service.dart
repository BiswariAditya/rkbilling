import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:rk_billing/widgets/amountInWOrds_section.dart';
import 'package:rk_billing/widgets/footer_section.dart';
import 'package:rk_billing/widgets/summary_section.dart';
import '../models/item.dart';
import '../providers/invoice_provider.dart';
import '../widgets/customer_section.dart';
import '../widgets/header_section.dart';
import '../widgets/invoice_table.dart';

Future<void> generatePdfInvoice(
    List<Item> items,
    String customerName,
    String customerAddress,
    String statCode,
    String gstNo,
    String phNo,
    String serialNo,
    String now,
    InvoiceProvider invoiceProvider) async {
  final pdf = pw.Document();

  // Load custom Unicode font with error handling
  final fontData = await rootBundle
      .load('assets/Roboto-VariableFont_wdth,wght.ttf')
      .catchError((error) {
    return Uint8List(0).buffer.asByteData();
  });
  final customFont = pw.Font.ttf(fontData);

  // Load logo and QR code from assets with error handling
  final logoBytes = await _loadAssetImage('assets/rk logo.jpg');
  final qrBytes = await _loadAssetImage('assets/rk qr.jpg');

  // Fetch dynamic taxation details from provider
  final subTotal = invoiceProvider.subtotal;
  final cgstRate = invoiceProvider.taxRate / 2;
  final sgstRate = invoiceProvider.taxRate / 2;
  final igstRate = invoiceProvider.taxRate;

  // Calculate tax amounts with proper formatting
  final cgstAmount = invoiceProvider.cgst.toStringAsFixed(2);
  final sgstAmount = invoiceProvider.sgst.toStringAsFixed(2);
  final igstAmount = invoiceProvider.igst.toStringAsFixed(2);

  // Convert total amount to words - handle numeric conversion
  final amountInWords =
      NumberToWord().convert('en-in', invoiceProvider.totalAmount.toInt());

  // Define theme for consistent styling
  final theme = pw.ThemeData.withFont(
    base: customFont,
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      // Adjusted margins for better fit
      build: (pw.Context context) {
        // Accurate measurement of components to ensure proper layout
        final availableHeight = context.page.pageFormat.availableHeight;

        // Fixed component heights (measured carefully)
        final companyHeaderHeight = 18.0;
        final headerSectionHeight = 70.0;
        final dividerHeight = 2.0;
        final customerSectionHeight = 48.0;
        final amountInWordsHeight = 22.0;
        final footerHeight = 80.0;
        final generatedByHeight = 12.0;
        final summaryHeight = 80.0;
        final spacingHeight = 25.0; // Total spacing between components

        // Calculate space needed for fixed components
        final fixedComponentsHeight = companyHeaderHeight +
            headerSectionHeight +
            (dividerHeight * 2) +
            customerSectionHeight +
            amountInWordsHeight +
            footerHeight +
            generatedByHeight +
            summaryHeight +
            spacingHeight;

        // Available space for table
        final tableHeight = availableHeight - fixedComponentsHeight;

        return pw.Container(
          padding: pw.EdgeInsets.all(0),
          // Remove extra padding to maximize space
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.max, // Take full height
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                padding: pw.EdgeInsets.only(bottom: 4),
                height: companyHeaderHeight,
                child: pw.Text('TAX INVOICE',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),

              pw.SizedBox(height: 3),

              // Header with logo and company info
              pw.Container(
                height: headerSectionHeight,
                child: HeaderWidget.buildHeaderSection(
                    logoBytes, qrBytes, serialNo, now, customFont),
              ),

              pw.SizedBox(height: 3),

              _buildDivider(),

              pw.SizedBox(height: 2),

              // Customer details
              pw.Container(
                height: customerSectionHeight,
                child: CustomerSection.buildCustomerSection(customerName,
                    customerAddress, statCode, gstNo, phNo, customFont),
              ),

              pw.SizedBox(height: 3),

              _buildDivider(),

              pw.SizedBox(height: 2),

              // Invoice table - with fixed height to ensure room for bottom components
              pw.Container(
                height: tableHeight,
                child: InvoiceTableWidget.buildExtendedInvoiceTable(
                    items, customFont),
              ),

              pw.SizedBox(height: 5),

              pw.Container(
                height: summaryHeight,
                child: SummarySection.buildSummarySection(
                    subTotal,
                    cgstRate,
                    sgstRate,
                    igstRate,
                    cgstAmount,
                    sgstAmount,
                    igstAmount,
                    invoiceProvider.totalAmount,
                    customFont),
              ),
              pw.SizedBox(height: 3),

              // Amount in words section
              pw.Container(
                height: amountInWordsHeight,
                child: AmountInWordsSection.buildAmountInWords(
                    amountInWords, customFont),
              ),

              pw.SizedBox(height: 3),

              pw.Container(
                height: footerHeight,
                child: FooterSection.buildFooterSection(customFont),
              ),

              pw.Container(
                height: generatedByHeight,
                alignment: pw.Alignment.center,
                child: pw.Text('Generated using RK-BillSoft',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    )),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdf.save());
}

// Helper method to load images with error handling
Future<Uint8List> _loadAssetImage(String assetPath) async {
  try {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    // For PNG images, use direct bytes without processing
    if (assetPath.toLowerCase().endsWith('.png')) {
      return bytes;
    }
    // For JPG, consider converting to PNG for better quality
    return bytes;
  } catch (e) {
    return Uint8List(0);
  }
}

// Build a consistent divider
pw.Widget _buildDivider() {
  return pw.Container(
    height: 0.5, // Thinner divider
    color: PdfColors.grey300,
  );
}
