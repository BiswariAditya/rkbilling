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
      margin: pw.EdgeInsets.all(10),
      build: (pw.Context context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(5),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                padding: pw.EdgeInsets.only(bottom: 4),
                child: pw.Text('TAX INVOICE',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.SizedBox(height: 5),

              // Header with logo and company info
              _buildHeaderSection(
                  logoBytes, qrBytes, serialNo, now, customFont),

              pw.SizedBox(height: 5),

              // Customer details
              _buildCustomerSection(customerName, customerAddress, statCode,
                  gstNo, phNo, customFont),

              pw.SizedBox(height: 5),

              // Invoice table - extended to fill available space with vertical lines
              pw.Expanded(
                child: _buildExtendedInvoiceTable(items, customFont),
              ),

              // Summary section (positioned just above footer)
              _buildSummarySection(
                  subTotal,
                  cgstRate,
                  sgstRate,
                  igstRate,
                  cgstAmount,
                  sgstAmount,
                  igstAmount,
                  invoiceProvider.totalAmount,
                  customFont),

              pw.SizedBox(height: 5),

              // Amount in words section
              _buildAmountInWords(amountInWords, customFont),

              pw.SizedBox(height: 5),

              // Footer section - now positioned at bottom with increased height
              _buildFooterSection(customFont),

              pw.SizedBox(height: 5),
              // Added more space after footer

              // Generator note
              pw.Center(
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

pw.Widget _buildExtendedInvoiceTable(List<Item> items, pw.Font customFont) {
  return pw.Container(
    // Add border to the entire table container to ensure margins are visible
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 0.5, color: PdfColors.black),
    ),
    child: pw.Column(
      children: [
        // Header row with distinct styling and proper margins
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: 25,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'S.No.',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  padding: pw.EdgeInsets.all(3), // Added padding for margins
                  decoration: _getVerticalBorder(),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Description',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Container(
                width: 40,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'HSN',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 45,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Size',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 35,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Sqft',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 30,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Qty.',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 45,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Total Sqft',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 45,
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                decoration: _getVerticalBorder(),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Rate',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                width: 60,
                decoration: _getVerticalBorder(),
                padding: pw.EdgeInsets.all(3),
                // Added padding for margins
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Amount',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Rest of the table with data rows
        pw.Expanded(
          child: pw.Stack(
            children: [
              // Container to show vertical lines extending to the bottom
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5, color: PdfColors.black),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(width: 25, decoration: _getVerticalBorder()),
                    // S.No
                    pw.Expanded(
                        flex: 4,
                        child: pw.Container(decoration: _getVerticalBorder())),
                    // Description
                    pw.Container(width: 40, decoration: _getVerticalBorder()),
                    // HSN
                    pw.Container(width: 45, decoration: _getVerticalBorder()),
                    // Size
                    pw.Container(width: 35, decoration: _getVerticalBorder()),
                    // sqft
                    pw.Container(width: 30, decoration: _getVerticalBorder()),
                    // Qty
                    pw.Container(width: 45, decoration: _getVerticalBorder()),
                    // Total Sq.
                    pw.Container(width: 45, decoration: _getVerticalBorder()),
                    // Rate
                    pw.Container(width: 60, decoration: _getVerticalBorder()),
                  ],
                ),
              ),

              // Data rows with vertical dividers
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return pw.Container(
                    decoration: pw.BoxDecoration(
                      color:
                          index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(width: 0.5, color: PdfColors.black),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 25,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent('${index + 1}'),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Container(
                            decoration: _getVerticalBorder(),
                            child: _buildTableCellContent(
                              items[index].description,
                              alignment: pw.Alignment.centerLeft,
                            ),
                          ),
                        ),
                        pw.Container(
                          width: 40,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].hsnCode > 0
                                ? items[index].hsnCode.toString()
                                : '',
                          ),
                        ),
                        pw.Container(
                          width: 45,
                          decoration: _getVerticalBorder(),
                          child:
                              _buildTableCellContent(items[index].sizeString),
                        ),
                        pw.Container(
                          width: 35,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].size > 0
                                ? items[index].size.toString()
                                : '',
                          ),
                        ),
                        pw.Container(
                          width: 30,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].quantity > 0
                                ? items[index].quantity.toString()
                                : '',
                          ),
                        ),
                        pw.Container(
                          width: 45,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].totalSqft > 0
                                ? items[index].totalSqft.toString()
                                : '',
                          ),
                        ),
                        pw.Container(
                          width: 45,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].rate > 0
                                ? '₹${items[index].rate.toStringAsFixed(2)}'
                                : '',
                          ),
                        ),
                        pw.Container(
                          width: 60,
                          decoration: _getVerticalBorder(),
                          child: _buildTableCellContent(
                            items[index].amount > 0
                                ? '₹${items[index].amount.toStringAsFixed(2)}'
                                : '',
                            alignment: pw.Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper for creating vertical borders for columns
pw.BoxDecoration _getVerticalBorder() {
  return pw.BoxDecoration(
    border: pw.Border.all(width: 0.5, color: PdfColors.black),
  );
}

// Helper for table cell content with reduced padding and font size
pw.Widget _buildTableCellContent(String text,
    {bool isHeader = false, pw.Alignment alignment = pw.Alignment.center}) {
  return pw.Container(
    padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
    alignment: alignment,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 7, // Smaller font size
        fontWeight: isHeader ? pw.FontWeight.bold : null,
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

pw.Widget _buildFooterSection(pw.Font customFont) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 3,
        child: pw.Container(
          padding: pw.EdgeInsets.all(3),
          height: 80, // Increased height to prevent content cropping
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Terms & Conditions:',
                  style: pw.TextStyle(
                      fontSize: 6, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                '1. Subject to Jhansi Jurisdiction. \n2. Goods sold are not returnable. \n3. Interest @ 25% per month on pending bills. \n4. Rs 500/- service charge for bounced cheques. \n5. Not responsible for typos. \n6. No liability for external conditions. \n7. Responsibility ceases after goods handover. \n8. E & O.E.',
                style: pw.TextStyle(fontSize: 5.5),
                maxLines: 8,
                // Increased max lines to ensure all content is shown
                overflow: pw.TextOverflow.clip,
              ),
              // Customer Signature
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Container(
                  width: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(width: 0.5)),
                  ),
                  padding: pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Customer Signature',
                    style: pw.TextStyle(fontSize: 6.5),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      pw.SizedBox(width: 5),

      // Authorized Signature Container
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          padding: pw.EdgeInsets.all(3),
          height: 70,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('FOR R. K. ADVERTISERS',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 25), // Increased space for signature

              // Authorized Signature
              pw.Container(
                width: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(width: 0.5)),
                ),
                padding: pw.EdgeInsets.only(top: 2),
                child: pw.Text(
                  'Authorised Signature',
                  style: pw.TextStyle(fontSize: 6.5),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
