import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/controllers/crab_purchase_controller.dart';
import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/daily_summary_controller.dart';
import '../../widgets/confirm_dialog.dart';
import 'invoice_edit_view.dart';
import 'invoice_pdf_view.dart';

class DailyInvoicesView extends StatelessWidget {
  final CrabPurchaseController crabPurchaseController =
      Get.put(CrabPurchaseController());
  final DailySummaryController dailySummaryController =
      Get.put(DailySummaryController());

  DailyInvoicesView({super.key}) {
    crabPurchaseController.fetchCrabPurchasesByDateRange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hóa đơn trong ngày',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              crabPurchaseController.fetchCrabPurchasesByDateRange();
              dailySummaryController.fetchAllDailySummariesByDepot();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (crabPurchaseController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (crabPurchaseController.crabPurchases.isEmpty) {
                return const Center(
                    child: Text('Không có hóa đơn nào trong ngày hôm nay.'));
              }
              return ListView.builder(
                itemCount: crabPurchaseController.crabPurchases.length,
                itemBuilder: (context, index) {
                  final crabPurchase =
                      crabPurchaseController.crabPurchases[index];
                  return Column(
                    children: [
                      Card(
                        color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title:
                              Text('Thương lái: ${crabPurchase.trader.name}'),
                          subtitle: Text(
                              'Tổng số tiền: ${formatCurrency(crabPurchase.totalCost)}'),
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DataTable(
                                    headingRowColor:
                                        WidgetStateColor.resolveWith(
                                            (states) => Colors.grey[300]!),
                                    columns: const [
                                      DataColumn(label: Text('Tên cua')),
                                      DataColumn(label: Text('Số kí (kg)')),
                                      DataColumn(label: Text('Giá VNĐ/kg')),
                                      DataColumn(label: Text('Tổng tiền')),
                                    ],
                                    rows: crabPurchase.crabs
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      var crabDetail = entry.value;
                                      return DataRow(cells: [
                                        DataCell(
                                            Text(crabDetail.crabType.name)),
                                        DataCell(Text(crabDetail.weight
                                            .toString()
                                            .replaceAll(',', '.'))),
                                        DataCell(Text(formatNumberWithoutSymbol(
                                            crabDetail.pricePerKg))),
                                        DataCell(Text(formatNumberWithoutSymbol(
                                            crabDetail.totalCost))),
                                      ]);
                                    }).toList(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: ButtonBar(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Colors.green,
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                          ),
                                          child: const Text('In',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16)),
                                          onPressed: () {
                                            Get.to(() => InvoicePdfView(
                                                crabPurchase: crabPurchase));
                                          },
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                          ),
                                          child: const Text('Sửa',
                                              style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 16)),
                                          onPressed: () {
                                            Get.to(() => EditInvoicePage(
                                                crabPurchase: crabPurchase));
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                                color: AppColors.errorColor,
                                                width: 2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                          ),
                                          child: const Text('Xóa',
                                              style: TextStyle(
                                                  color: AppColors.errorColor,
                                                  fontSize: 16)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmationDialog(
                                                  title: 'Xác nhận xóa',
                                                  content:
                                                      'Bạn có chắc chắn muốn xóa hóa đơn này không?',
                                                  onConfirm: () {
                                                    crabPurchaseController
                                                        .deleteCrabPurchase(
                                                            crabPurchase.id);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1.0,
                        height: 20.0,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton.icon(
              onPressed: () async {
                await crabPurchaseController.createDailySummary();
              },
              icon: const Icon(Icons.save, color: Colors.green),
              label: const Text(
                'Tạo báo cáo cuối ngày',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
