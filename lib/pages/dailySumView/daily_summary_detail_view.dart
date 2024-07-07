import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/crabtype_controller.dart';
import '../../models/dailysummary_model.dart';

class DailySummaryDetailView extends StatelessWidget {
  final DailySummary dailySummary;
  final AuthController authController = Get.find<AuthController>();
  final CrabTypeController crabTypeController = Get.find<CrabTypeController>();

  DailySummaryDetailView({super.key, required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    final depotName = authController.user.value?.depotName ?? 'Tên vựa cua';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tổng hợp trong ngày'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdfFile = await _generatePdf(dailySummary, depotName);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(file: pdfFile),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tên vựa: $depotName',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Ngày: ${dailySummary.createdAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tổng số tiền: ${formatCurrency(dailySummary.totalAmount)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Loại cua')),
                      DataColumn(label: Text('Trọng lượng (Kg)')),
                      DataColumn(label: Text('Tổng tiền')),
                    ],
                    rows: dailySummary.details.map((detail) {
                      final crabTypeName = crabTypeController
                          .getCrabTypeNameById(detail.crabType);
                      return DataRow(cells: [
                        DataCell(Text(crabTypeName)),
                        DataCell(Text(formatWeight(detail.totalWeight))),
                        DataCell(Text(formatCurrency(detail.totalCost))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatWeight(double weight) {
    if (weight % 1 == 0) {
      return weight.toStringAsFixed(0);
    } else {
      return weight.toStringAsFixed(2);
    }
  }

  Future<File> _generatePdf(DailySummary dailySummary, String depotName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Báo cáo tổng hợp trong ngày',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 16),
            pw.Text(
              'Tên vựa: $depotName',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Ngày: ${dailySummary.createdAt.toLocal().toString().split(' ')[0]}',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Tổng số tiền: ${formatCurrency(dailySummary.totalAmount)}',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              headers: <String>['Loại cua', 'Trọng lượng', 'Tổng tiền'],
              data: dailySummary.details
                  .map((detail) => [
                        crabTypeController.getCrabTypeNameById(detail.crabType),
                        formatWeight(detail.totalWeight),
                        formatCurrency(detail.totalCost),
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(path.join(output.path, 'bao_cao_tong_hop.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

class PdfViewerPage extends StatelessWidget {
  final File file;

  const PdfViewerPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem PDF'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}
