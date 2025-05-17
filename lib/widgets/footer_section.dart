import 'package:pdf/widgets.dart' as pw;

class FooterSection {
  static pw.Widget buildFooterSection(pw.Font customFont) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: pw.EdgeInsets.all(4), // Consistent padding
            height: 70, // Fixed height
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
                  maxLines: 8, // Allow more lines to prevent cutoff
                  overflow: pw.TextOverflow.clip,
                ),
                pw.SizedBox(height: 2), // Consistent spacing

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
            padding: pw.EdgeInsets.all(4), // Consistent padding
            height: 70, // Fixed height
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
                pw.SizedBox(height: 12), // Space for signature

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
}
