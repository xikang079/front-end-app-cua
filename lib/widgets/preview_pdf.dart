import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final pw.Document pdf;

  const PdfPreviewScreen({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước PDF'),
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
