import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/item.dart';

class InvoiceTableWidget {
  static pw.Widget buildExtendedInvoiceTable(List<Item> items, pw.Font customFont) {
    return pw.Container(
      child: pw.Table(
        border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey800),
        columnWidths: {
          0: pw.FixedColumnWidth(20),
          1: pw.FlexColumnWidth(4),
          2: pw.FixedColumnWidth(40),
          3: pw.FixedColumnWidth(45),
          4: pw.FixedColumnWidth(35),
          5: pw.FixedColumnWidth(30),
          6: pw.FixedColumnWidth(45),
          7: pw.FixedColumnWidth(45),
          8: pw.FixedColumnWidth(60),
        },
        tableWidth: pw.TableWidth.max,
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              buildTableCell('S.No.', isHeader: true),
              buildTableCell('Description', isHeader: true, alignment: pw.Alignment.centerLeft),
              buildTableCell('HSN', isHeader: true),
              buildTableCell('Size', isHeader: true),
              buildTableCell('Sqft', isHeader: true),
              buildTableCell('Qty.', isHeader: true),
              buildTableCell('Total Sq.', isHeader: true),
              buildTableCell('Rate', isHeader: true),
              buildTableCell('Amount', isHeader: true),
            ],
          ),
          for (int i = 0; i < items.length; i++)
            pw.TableRow(
              decoration: i % 2 == 0
                  ? pw.BoxDecoration(color: PdfColors.white)
                  : pw.BoxDecoration(color: PdfColors.grey50),
              children: [
                buildTableCell('${i + 1}'),
                buildTableCell(items[i].description, alignment: pw.Alignment.centerLeft),
                buildTableCell(items[i].hsnCode > 0 ? items[i].hsnCode.toString() : ''),
                buildTableCell(items[i].sizeString),
                buildTableCell(items[i].size > 0 ? items[i].size.toString() : ''),
                buildTableCell(items[i].quantity > 0 ? items[i].quantity.toString() : ''),
                buildTableCell(items[i].totalSqft > 0 ? items[i].totalSqft.toString() : ''),
                buildTableCell(items[i].rate > 0 ? '₹${items[i].rate.toStringAsFixed(2)}' : ''),
                buildTableCell(
                  items[i].amount > 0 ? '₹${items[i].amount.toStringAsFixed(2)}' : '',
                  alignment: pw.Alignment.centerRight,
                ),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget buildTableCell(String text, {
    bool isHeader = false,
    pw.Alignment alignment = pw.Alignment.center,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}
