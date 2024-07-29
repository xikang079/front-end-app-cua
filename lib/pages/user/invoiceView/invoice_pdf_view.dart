import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../../models/crabpurchase_model.dart' as purchaseModel;
import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../widgets/printer_dialog.dart';

class InvoicePdfView extends StatefulWidget {
  final purchaseModel.CrabPurchase crabPurchase;

  const InvoicePdfView({super.key, required this.crabPurchase});

  @override
  _InvoicePdfViewState createState() => _InvoicePdfViewState();
}

class _InvoicePdfViewState extends State<InvoicePdfView> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final isConnected = await bluetooth.isConnected;
    setState(() {
      _isConnected = isConnected!;
    });
  }

  void _showPrinterDialog() {
    showDialog(
      context: context,
      builder: (context) => PrinterDialog(
        onDeviceSelected: (device) async {
          setState(() {
            _isConnected = true;
          });
          await _printReceipt();
        },
      ),
    );
  }

  String formatLine(String stt, String left, String middle, String right) {
    const int sttWidth = 8;
    const int leftWidth = 10;
    const int middleWidth = 12;
    const int rightWidth = 15;

    String paddedSTT = stt.padRight(sttWidth);
    String paddedLeft = left.padRight(leftWidth);
    String paddedMiddle = middle.padLeft(middleWidth);
    String paddedRight = right.padLeft(rightWidth);

    return "$paddedSTT$paddedLeft$paddedMiddle$paddedRight";
  }

  Future<void> _printReceipt() async {
    if (_isConnected) {
      try {
        // Tiêu đề
        bluetooth.printCustom("\x1B\x45\x01HOA DON MUA CUA\x1B\x45\x00", 2, 1);
        bluetooth.printNewLine();

        // Thông tin người bán và thời gian
        bluetooth.printCustom(
            "Ten lai: ${removeDiacritics(widget.crabPurchase.trader.name)}",
            2,
            0);
        String formattedDateTime =
            DateFormat('HH:mm dd-MM-yyyy').format(DateTime.now());
        bluetooth.printCustom("Thoi gian: $formattedDateTime", 1, 0);
        bluetooth.printNewLine();

        // Đường kẻ ngang
        bluetooth.printCustom("-".padRight(32, '-'), 1, 1);

        bluetooth.printCustom(
            formatLine("STT", "Loai cua", "So kg", "Gia cua"), 1, 0);
        for (int i = 0; i < widget.crabPurchase.crabs.length; i++) {
          var crabDetail = widget.crabPurchase.crabs[i];
          bluetooth.printCustom(
            formatLine(
              (i + 1).toString(),
              crabDetail.crabType.name,
              crabDetail.weight.toString(),
              formatNumberWithoutSymbol(crabDetail.pricePerKg),
            ),
            3,
            0,
          );
        }

        // Đường kẻ ngang
        bluetooth.printCustom("-".padRight(32, '-'), 1, 1);

        // Tổng cộng
        bluetooth.printCustom(
            formatLine("Tong cong:", "", "",
                formatNumberWithoutSymbol(widget.crabPurchase.totalCost)),
            3,
            0);

        bluetooth.printNewLine();
        bluetooth.printCustom("Cam on quy khach!", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'In không thành công: $e',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } else {
      _showPrinterDialog();
    }
  }

  Future<Uint8List> _generatePdf() async {
    final ttf = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final font = pw.Font.ttf(ttf.buffer.asByteData());
    final boldTtf = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final boldFont = pw.Font.ttf(boldTtf.buffer.asByteData());
    final doc = pw.Document();

    // Lấy thông tin tên cua từ controller và tạo danh sách dữ liệu cho bảng
    final List<List<String>> data =
        widget.crabPurchase.crabs.asMap().entries.map((entry) {
      int index = entry.key;
      var crabDetail = entry.value;
      return [
        (index + 1).toString(),
        crabDetail.crabType.name,
        crabDetail.weight.toString(),
        formatNumberWithoutSymbol(crabDetail.pricePerKg),
      ];
    }).toList();

    const pageFormat = PdfPageFormat(
      80 * PdfPageFormat.mm, // Chiều rộng cho máy in 80mm
      double.infinity,
      marginTop: 10, // Đặt marginTop thành 10
      marginBottom: 10, // Đặt marginBottom thành 10
      marginLeft: 5, // Đặt marginLeft thành 5 để căn chỉnh về bên phải một chút
      marginRight:
          5, // Đặt marginRight thành 5 để căn chỉnh về bên trái một chút
    );

    // Thêm trang vào tài liệu
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Hóa đơn mua cua',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20, // Tăng kích cỡ chữ để dễ đọc hơn
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Thương nhân: ${widget.crabPurchase.trader.name}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14, // Tăng kích cỡ chữ
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headers: [
                  'STT',
                  'Tên Cua',
                  'Số KG',
                  'Giá Cua',
                ],
                data: data,
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14, // Tăng kích cỡ chữ
                ),
                cellStyle: pw.TextStyle(
                  font: font,
                  fontSize: 12, // Tăng kích cỡ chữ
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.65),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(0.8),
                  3: const pw.FlexColumnWidth(1.1),
                },
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Tổng cộng: ${formatCurrency(widget.crabPurchase.totalCost)}',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16, // Tăng kích cỡ chữ
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Xin cảm ơn - Hẹn gặp lại!',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12, // Tăng kích cỡ chữ
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  void dispose() {
    // Không ngắt kết nối tại đây để giữ kết nối máy in toàn cục
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn PDF', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReceipt,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          return _generatePdf();
        },
        onPrinted: (context) {
          Navigator.pop(context, true);
          FocusScope.of(context).unfocus();
        },
        onShared: (context) {
          Navigator.pop(context, true);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
