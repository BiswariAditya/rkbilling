import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:number_to_words/number_to_words.dart';
import '../models/item.dart';
import '../providers/invoice_provider.dart';

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
    print('Error loading font: $error');
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
      margin: pw.EdgeInsets.all(8), // Reduced page margin
      build: (pw.Context context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(5), // Reduced container padding
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section with improved styling
              pw.Container(
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                padding: pw.EdgeInsets.only(bottom: 4), // Reduced padding
                child: pw.Text('TAX INVOICE',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.SizedBox(height: 5), // Reduced spacing
              _buildHeaderSection(
                  logoBytes, qrBytes, serialNo, now, customFont),

              pw.SizedBox(height: 5), // Reduced spacing
              _buildDivider(),
              pw.SizedBox(height: 3), // Reduced spacing

              // Customer details section with better formatting
              _buildCustomerSection(customerName, customerAddress, statCode,
                  gstNo, phNo, customFont),

              pw.SizedBox(height: 5), // Reduced spacing
              _buildDivider(),
              pw.SizedBox(height: 3), // Reduced spacing

              // Invoice table with improved spacing and borders
              _buildInvoiceTable(items, customFont),

              pw.SizedBox(height: 5), // Reduced spacing

              // Summary section with better alignment
              _buildSummarySection(subTotal, cgstRate, sgstRate, igstRate,
                  cgstAmount, sgstAmount, igstAmount, subTotal, customFont),

              // Amount in words with better styling
              pw.SizedBox(height: 5), // Reduced spacing
              _buildAmountInWords(amountInWords, customFont),

              // Terms and signatures with improved layout
              pw.SizedBox(height: 5), // Reduced spacing
              _buildFooterSection(customFont),

              pw.SizedBox(height: 3), // Reduced spacing
              pw.Center(
                child: pw.Text('Generated using RK-BillSoft',
                    style:
                    pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
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
    print('Error loading asset $assetPath: $e');
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

// Build the header section with logo and company details
pw.Widget _buildHeaderSection(Uint8List logoBytes, Uint8List qrBytes,
    String serialNo, String now, pw.Font customFont) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Image(
        pw.MemoryImage(
            logoBytes,
          dpi: 300,
        ),
        width: 120, // Reduced logo size
        height: 60,
        fit: pw.BoxFit.fill,
        dpi: 300,
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('GST No: 09ANEPG2598L1ZI',
                      style: pw.TextStyle(fontSize: 8)), // Smaller font
                  pw.Text('Indian Overseas Bank',
                      style: pw.TextStyle(fontSize: 8)),
                  pw.Text('A/C NO: 056502000001372',
                      style: pw.TextStyle(fontSize: 8)),
                  pw.Text('IFSC Code: IOBA0000565',
                      style: pw.TextStyle(fontSize: 8)),
                  pw.Text('Ph: 9450080432, 0510-2361494',
                      style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(width: 5), // Reduced spacing
              pw.Image(
                pw.MemoryImage(qrBytes),
                width: 50, // Reduced QR code size
                height: 50,
                fit: pw.BoxFit.contain,
              ),
            ],
          ),
          pw.SizedBox(height: 3), // Reduced spacing
          pw.Container(
            padding: pw.EdgeInsets.all(2), // Reduced padding
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Serial No: $serialNo',
                    style: pw.TextStyle(fontSize: 8)),
                pw.Text('Date: $now', style: pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

// Build the customer details section
pw.Widget _buildCustomerSection(String customerName, String customerAddress,
    String statCode, String gstNo, String phNo, pw.Font customFont) {
  return pw.Container(
    padding: pw.EdgeInsets.all(5), // Reduced padding
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 0.5),
      borderRadius: pw.BorderRadius.circular(2),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('M/s. $customerName',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2), // Reduced spacing
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Address: ',
                style:
                pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(
              child: pw.Text(customerAddress, style: pw.TextStyle(fontSize: 8)),
            ),
          ],
        ),
        pw.SizedBox(height: 2), // Reduced spacing
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('State Code:',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 2),
                  pw.Text(statCode, style: pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
            pw.SizedBox(width: 5), // Reduced spacing
            pw.Expanded(
              flex: 2,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('GST No:',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 2),
                  pw.Text(gstNo, style: pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
            pw.SizedBox(width: 5), // Reduced spacing
            pw.Expanded(
              flex: 1,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Ph No:',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 2),
                  pw.Text(phNo, style: pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Build the invoice items table with optimized sizes
pw.Widget _buildInvoiceTable(List<Item> items, pw.Font customFont) {
  return pw.Table(
    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey800),
    columnWidths: {
      0: pw.FixedColumnWidth(20), // S.No - smaller
      1: pw.FlexColumnWidth(4), // Description
      2: pw.FixedColumnWidth(40), // HSN - smaller
      3: pw.FixedColumnWidth(45), // Size
      4: pw.FixedColumnWidth(35), // sqft - smaller
      5: pw.FixedColumnWidth(30), // Qty - smaller
      6: pw.FixedColumnWidth(45), // Total Sq. - smaller
      7: pw.FixedColumnWidth(45), // Rate - smaller
      8: pw.FixedColumnWidth(60), // Amount - smaller
    },
    tableWidth: pw.TableWidth.max,
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      // Header row with distinct styling
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _buildTableCell('S.No.', isHeader: true),
          _buildTableCell('Description',
              isHeader: true, alignment: pw.Alignment.centerLeft),
          _buildTableCell('HSN', isHeader: true),
          _buildTableCell('Size', isHeader: true),
          _buildTableCell('Sqft', isHeader: true),
          _buildTableCell('Qty.', isHeader: true),
          _buildTableCell('Total Sq.', isHeader: true),
          _buildTableCell('Rate', isHeader: true),
          _buildTableCell('Amount', isHeader: true),
        ],
      ),
      // Data rows with alternating background
      for (int i = 0; i < items.length; i++)
        pw.TableRow(
          decoration: i % 2 == 0
              ? pw.BoxDecoration(color: PdfColors.white)
              : pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildTableCell('${i + 1}'),
            _buildTableCell(items[i].description,
                alignment: pw.Alignment.centerLeft),
            _buildTableCell(items[i].hsnCode.toString()),
            _buildTableCell(items[i].sizeString),
            _buildTableCell(items[i].size.toString()),
            _buildTableCell(items[i].quantity.toString()),
            _buildTableCell(items[i].totalSqft.toString()),
            _buildTableCell('₹${items[i].rate.toStringAsFixed(2)}'),
            _buildTableCell('₹${items[i].amount.toStringAsFixed(2)}',
                alignment: pw.Alignment.centerRight),
          ],
        ),
    ],
  );
}

// Helper for table cells with reduced padding and font size
pw.Widget _buildTableCell(String text,
    {bool isHeader = false, pw.Alignment alignment = pw.Alignment.center}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2), // Reduced padding
    child: pw.Align(
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7, // Smaller font size
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    ),
  );
}

// Build the summary section with tax calculations
pw.Widget _buildSummarySection(
    num subTotal,
    num cgstRate,
    num sgstRate,
    num igstRate,
    String cgstAmount,
    String sgstAmount,
    String igstAmount,
    num totalAmount,
    pw.Font customFont) {
  return pw.Row(
    children: [
      pw.Expanded(flex: 7, child: pw.Container()),
      pw.Container(
        width: 180, // Reduced width
        child: pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            _buildSummaryRow('Less/Advance/Discount', ''),
            _buildSummaryRow('Freight/Loading/cartage', ''),
            _buildSummaryRow(
                'Taxable Amount', 'Rs. ${subTotal.toStringAsFixed(2)}',
                isTotal: true),
            _buildSummaryRow('CGST @ $cgstRate%', 'Rs. $cgstAmount'),
            _buildSummaryRow('SGST @ $sgstRate%', 'Rs. $sgstAmount'),
            _buildSummaryRow('IGST @ $igstRate%', 'Rs. $igstAmount'),
            _buildSummaryRow(
                'Total Amount', 'Rs. ${totalAmount.toStringAsFixed(2)}',
                isTotal: true),
          ],
        ),
      ),
    ],
  );
}

// Helper for summary rows with reduced padding and font size
pw.TableRow _buildSummaryRow(String label, String amount,
    {bool isTotal = false}) {
  return pw.TableRow(
    decoration: isTotal ? pw.BoxDecoration(color: PdfColors.grey200) : null,
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(3), // Reduced padding
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 8, // Smaller font size
            fontWeight: isTotal ? pw.FontWeight.bold : null,
          ),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(3), // Reduced padding
        child: pw.Text(
          amount,
          style: pw.TextStyle(
            fontSize: 8, // Smaller font size
            fontWeight: isTotal ? pw.FontWeight.bold : null,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ],
  );
}

// Build the amount in words section
pw.Widget _buildAmountInWords(String amountInWords, pw.Font customFont) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 0.5),
      borderRadius: pw.BorderRadius.circular(2),
      color: PdfColors.grey50,
    ),
    padding: pw.EdgeInsets.all(3), // Reduced padding
    child: pw.Row(
      children: [
        pw.Text(
          'Amount in Words: ',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(
          child: pw.Text(
            'Rupees $amountInWords Only',
            style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ),
  );
}

// Build the footer section with more compact terms and signatures
pw.Widget _buildFooterSection(pw.Font customFont) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 3,
        child: pw.Container(
          padding: pw.EdgeInsets.all(4), // Reduced padding
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Terms & Conditions:',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2), // Reduced spacing
              // Terms as a compact block of text to save space
              pw.Text(
                  '1. All Subject to Jhansi Jurisdiction Only. 2. Goods once sold are neither returnable nor exchangeable. 3. Interest @ 25% per month will be charged on Pending Bills. 4. Cheque unpaid from bank on presentation at due are subjected to a service charge of Rs 500/-. 5. R.K. Advertisers is not responsible for any typing or printing mistakes. 6. Advertising agency is not responsible for untoward conditions. 7. Our responsibility ceases after handing over the goods to transport or your representative. 8. E & O.E.',
                  style: pw.TextStyle(fontSize: 6), // Very small font
                  maxLines: 10,
                  overflow: pw.TextOverflow.clip),
              pw.SizedBox(height: 4), // Reduced spacing
              pw.Container(
                width: 80, // Smaller signature line
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(width: 0.5))),
                padding: pw.EdgeInsets.only(top: 2), // Reduced padding
                child: pw.Text('Customer Signature',
                    style: pw.TextStyle(fontSize: 7)),
              ),
            ],
          ),
        ),
      ),
      pw.SizedBox(width: 5), // Reduced spacing
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          padding: pw.EdgeInsets.all(4), // Reduced padding
          height: 80, // Reduced container height
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.SizedBox(height: 2), // Reduced spacing
              pw.Text('FOR R. K. ADVERTISERS',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15), // Space for signature
              pw.Container(
                width: 80, // Smaller signature line
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(width: 0.5))),
                padding: pw.EdgeInsets.only(top: 2), // Reduced padding
                child: pw.Text('Authorised Signature',
                    style: pw.TextStyle(fontSize: 7)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}