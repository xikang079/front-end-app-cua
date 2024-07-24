import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crabtype_controller.dart';
import '../../models/dailysummary_model.dart';

class DailySummaryDetailView extends StatelessWidget {
  final DailySummary dailySummary;

  const DailySummaryDetailView({super.key, required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    final CrabTypeController crabTypeController =
        Get.find<CrabTypeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Báo cáo tổng hợp trong ngày',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('STT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Loại cua',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Số kí (Kg)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tổng tiền',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  ...dailySummary.details.asMap().entries.map((entry) {
                    int index = entry.key;
                    var detail = entry.value;
                    final crabTypeName =
                        crabTypeController.getCrabTypeNameById(detail.crabType);
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((index + 1).toString(),
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(crabTypeName,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(formatWeight(detail.totalWeight),
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(formatCurrency(detail.totalCost),
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
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
}
