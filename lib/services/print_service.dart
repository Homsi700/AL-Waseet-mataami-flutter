import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  Future<void> printReceipt(Order order) async {
    final pdf = pw.Document();

    // Load Arabic font
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'الوسيط للوجبات السريعة',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'فاتورة ضريبية مبسطة',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'رقم الفاتورة: ${order.id}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.Text(
                  'التاريخ: ${DateFormat('yyyy-MM-dd').format(order.dateTime)}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.Text(
                  'الوقت: ${DateFormat('HH:mm:ss').format(order.dateTime)}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                
                // Customer info if available
                if (order.customerName != null && order.customerName!.isNotEmpty)
                  pw.Text(
                    'العميل: ${order.customerName}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                  pw.Text(
                    'الهاتف: ${order.customerPhone}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                if (order.customerAddress != null && order.customerAddress!.isNotEmpty)
                  pw.Text(
                    'العنوان: ${order.customerAddress}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                if (order.customerName != null && order.customerName!.isNotEmpty)
                  pw.SizedBox(height: 10),
                
                // Order type and payment method
                pw.Text(
                  'نوع الطلب: ${order.orderType}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.Text(
                  'طريقة الدفع: ${order.paymentMethod}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                
                // Divider
                pw.Divider(thickness: 1),
                
                // Table header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'الكمية',
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'الصنف',
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'السعر',
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'الإجمالي',
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1),
                
                // Items
                pw.Column(
                  children: order.items.map((item) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${item.quantity}',
                                style: pw.TextStyle(font: font, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                item.product.name,
                                style: pw.TextStyle(font: font, fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${item.product.price.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font, fontSize: 10),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${item.totalPrice.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font, fontSize: 10),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        // Notes if available
                        if (item.notes.isNotEmpty)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 20),
                            child: pw.Text(
                              'ملاحظات: ${item.notes.join(', ')}',
                              style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic),
                            ),
                          ),
                        pw.SizedBox(height: 2),
                      ],
                    );
                  }).toList(),
                ),
                
                // Divider
                pw.Divider(thickness: 1),
                
                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الإجمالي:',
                      style: pw.TextStyle(font: boldFont, fontSize: 12),
                    ),
                    pw.Text(
                      '${order.totalAmount.toStringAsFixed(2)} ريال',
                      style: pw.TextStyle(font: boldFont, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                
                // Footer
                pw.Text(
                  'شكراً لزيارتكم',
                  style: pw.TextStyle(font: font, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'الوسيط للوجبات السريعة',
                  style: pw.TextStyle(font: font, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}