import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/controllers/crab_purchase_controller.dart';
import 'package:project_crab_front_end/widgets/confirm_dialog.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import 'invoice_edit_view.dart';

class DailyInvoicesView extends StatelessWidget {
  final CrabPurchaseController crabPurchaseController =
      Get.put(CrabPurchaseController());

  DailyInvoicesView({super.key}) {
    final DateTime today = DateTime.now().toUtc().add(const Duration(hours: 7));
    crabPurchaseController.fetchCrabPurchasesByDate(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa đơn trong ngày'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final DateTime today =
                  DateTime.now().toUtc().add(const Duration(hours: 7));
              crabPurchaseController.fetchCrabPurchasesByDate(today);
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
                  return ExpansionTile(
                    title: Text('Thương nhân: ${crabPurchase.trader.name}'),
                    subtitle: Text(
                        'Tổng số tiền: ${formatCurrency(crabPurchase.totalCost)}'),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: crabPurchase.crabs.length,
                        itemBuilder: (context, crabIndex) {
                          final crabDetail = crabPurchase.crabs[crabIndex];
                          return ListTile(
                            title: Text(crabDetail.crabType.name),
                            subtitle: Text(
                              'Trọng lượng: ${crabDetail.weight}, Giá: ${formatCurrency(crabDetail.pricePerKg)}, Tổng: ${formatCurrency(crabDetail.totalCost)}',
                            ),
                          );
                        },
                      ),
                      ButtonBar(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.to(() =>
                                  EditInvoicePage(crabPurchase: crabPurchase));
                            },
                            child: const Text('Sửa'),
                          ),
                          ElevatedButton(
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
                                          .deleteCrabPurchase(crabPurchase.id);
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await crabPurchaseController.createDailySummary();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Tạo báo cáo tổng hợp',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
