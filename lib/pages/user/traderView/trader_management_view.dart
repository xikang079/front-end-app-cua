import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shimmer/shimmer.dart';

import '../../../apps/config/app_colors.dart';
import '../../../controllers/trader_controller.dart';
import '../../../controllers/crab_purchase_controller.dart';
import '../../../models/trader_model.dart';
import '../../../widgets/confirm_dialog.dart';

class TraderManagementView extends StatelessWidget {
  const TraderManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final TraderController traderController = Get.put(TraderController());
    final CrabPurchaseController crabPurchaseController =
        Get.put(CrabPurchaseController());

    void showTraderForm([Trader? trader]) {
      TextEditingController nameController =
          TextEditingController(text: trader?.name ?? '');
      TextEditingController phoneController =
          TextEditingController(text: trader?.phone ?? '');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(trader == null ? 'Thêm thương lái' : 'Sửa thương lái',
                style: const TextStyle(color: AppColors.primaryColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lái',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'SĐT Lái',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty) {
                    Trader newTrader = Trader(
                      id: trader?.id ?? '',
                      name: nameController.text,
                      phone: phoneController.text,
                    );
                    if (trader == null) {
                      traderController.createTrader(newTrader);
                    } else {
                      traderController.updateTrader(trader.id, newTrader);
                    }
                    Navigator.of(context).pop();
                  } else {
                    traderController.showSnackbar('Lỗi',
                        'Vui lòng nhập đầy đủ thông tin', AppColors.errorColor);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    }

    Future<bool> showConfirmationDialog() async {
      return await showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Xác nhận',
              content: 'Bạn có chắc chắn muốn xóa thương lái này không?',
              onConfirm: () {
                // Navigator.of(context).pop(true);
              },
            ),
          ) ??
          false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lí thương lái',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              traderController.fetchTraders();
              crabPurchaseController
                  .fetchCrabPurchasesByDateRange(); // Refresh data mỗi khi giao diện được load lại
            },
          ),
        ],
      ),
      body: Obx(() {
        if (traderController.isLoading.value) {
          return _buildShimmerEffect();
        }
        if (traderController.traders.isEmpty) {
          return const Center(child: Text('Không có thương lái nào'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StickyHeader(
              header: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(3),
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
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tên lái',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('SĐT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Trạng thái',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Hành động',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(3),
                },
                children: traderController.traders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Trader trader = entry.value;
                  bool hasSold = crabPurchaseController.hasSoldCrabs(trader.id);
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text((index + 1).toString(),
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(trader.name,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(trader.phone,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            hasSold ? 'Đã bán' : 'Chưa bán',
                            style: TextStyle(
                                fontSize: 14,
                                color: hasSold ? Colors.green : Colors.red),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                child: const Text('Sửa',
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 16)),
                                onPressed: () {
                                  showTraderForm(trader);
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.errorColor, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                child: const Text('Xóa',
                                    style: TextStyle(
                                        color: AppColors.errorColor,
                                        fontSize: 16)),
                                onPressed: () async {
                                  bool confirmed =
                                      await showConfirmationDialog();
                                  if (confirmed) {
                                    traderController.deleteTrader(trader.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: TextButton.icon(
                onPressed: () => showTraderForm(),
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text(
                  'Thêm lái',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
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
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: const ListTile(
                title: Text(''),
                subtitle: Text(''),
              ),
            ),
          );
        },
      ),
    );
  }
}
