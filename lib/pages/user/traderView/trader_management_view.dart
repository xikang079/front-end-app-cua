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
    // Giữ cách dùng controller giống trang Loại cua: đơn giản, an toàn
    final traderController = Get.isRegistered<TraderController>()
        ? Get.find<TraderController>()
        : Get.put(TraderController());

    final crabPurchaseController = Get.isRegistered<CrabPurchaseController>()
        ? Get.find<CrabPurchaseController>()
        : Get.put(CrabPurchaseController());

    // ====== FORM THÊM / SỬA ======
    void showTraderForm([Trader? trader]) {
      final nameController = TextEditingController(text: trader?.name ?? '');
      final phoneController = TextEditingController(text: trader?.phone ?? '');

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              trader == null ? 'Thêm thương lái' : 'Sửa thương lái',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lái',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'SĐT ',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    traderController.showSnackbar(
                      'Lỗi',
                      'Vui lòng nhập đầy đủ thông tin',
                      AppColors.errorColor,
                    );
                    return;
                  }

                  final model = Trader(
                    id: trader?.id ?? '',
                    name: nameController.text,
                    phone: phoneController.text,
                  );

                  if (trader == null) {
                    traderController.createTrader(model);
                  } else {
                    traderController.updateTrader(trader.id, model);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    }

    Future<bool> showDeleteConfirm(VoidCallback onConfirm) async {
      return await showDialog(
            context: context,
            builder: (_) => ConfirmationDialog(
              title: 'Xác nhận',
              content: 'Bạn có chắc chắn muốn xóa thương lái này không?',
              onConfirm: onConfirm,
            ),
          ) ??
          false;
    }

    // ====== HEADER NHẸ NHÀNG ======
    Widget buildHeaderBar() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.people_alt, color: AppColors.primaryColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Danh sách thương lái',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // OutlinedButton.icon(
            //   onPressed: () => showTraderForm(),
            //   icon: const Icon(Icons.add, color: AppColors.primaryColor),
            //   label: const Text(
            //     'Thêm lái',
            //     style: TextStyle(color: AppColors.primaryColor),
            //   ),
            //   style: OutlinedButton.styleFrom(
            //     side: const BorderSide(color: AppColors.primaryColor, width: 2),
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10)),
            //   ),
            // ),
          ],
        ),
      );
    }

    // ====== TABLE HEADER/CELL ======
    TableRow buildTableHeaderRow() {
      Widget cell(String text, {TextAlign align = TextAlign.left}) => Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Text(
              text,
              textAlign: align,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          );

      return TableRow(
        children: [
          cell('STT', align: TextAlign.center),
          cell('Tên lái'),
          cell('SĐT'),
          cell('Trạng thái', align: TextAlign.center),
          cell('Hành động', align: TextAlign.center),
        ],
      );
    }

    TableRow buildTraderRow(int index, Trader trader) {
      final hasSold = crabPurchaseController.hasSoldCrabs(trader.id);

      return TableRow(
        decoration: const BoxDecoration(color: Colors.white),
        children: [
          _td(
            Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            align: Alignment.center,
          ),
          _td(
            Text(
              trader.name,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          _td(
            Text(
              trader.phone,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  color: hasSold ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: hasSold ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  hasSold ? 'Đã bán' : 'Chưa bán',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: hasSold ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => showTraderForm(trader),
                  child: const Text(
                    'Sửa',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final ok = await showDeleteConfirm(() {
                      traderController.deleteTrader(trader.id);
                    });
                    if (ok) {}
                  },
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: AppColors.errorColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lí thương lái',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              traderController.fetchTraders();
              crabPurchaseController.fetchCrabPurchasesByDateRange();
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildHeaderBar(),
              const SizedBox(height: 12),

              // StickyHeader giống trang "Loại cua"
              StickyHeader(
                header: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Table(
                    // Tỉ lệ cột tương đương phong cách trang Loại cua
                    columnWidths: const {
                      0: FlexColumnWidth(1), // STT
                      1: FlexColumnWidth(2.3), // Tên
                      2: FlexColumnWidth(1.5), // SĐT
                      3: FlexColumnWidth(1.5), // Trạng thái
                      4: FlexColumnWidth(3), // Hành động
                    },
                    border: const TableBorder(
                      horizontalInside:
                          BorderSide(color: Colors.black26, width: 0.5),
                      verticalInside:
                          BorderSide(color: Colors.black26, width: 0.5),
                      top: BorderSide(color: Colors.black26, width: 1),
                      left: BorderSide(color: Colors.black26, width: 1),
                      right: BorderSide(color: Colors.black26, width: 1),
                    ),
                    children: [buildTableHeaderRow()],
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1), // STT
                      1: FlexColumnWidth(2.3), // Tên
                      2: FlexColumnWidth(1.5), // SĐT
                      3: FlexColumnWidth(1.5), // Trạng thái
                      4: FlexColumnWidth(3), // Hành động
                    },
                    border: const TableBorder(
                      horizontalInside:
                          BorderSide(color: Colors.black12, width: 0.5),
                      verticalInside:
                          BorderSide(color: Colors.black12, width: 0.5),
                    ),
                    children: traderController.traders
                        .asMap()
                        .entries
                        .map((e) => buildTraderRow(e.key, e.value))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 80), // chừa chỗ cho bottom bar
            ],
          ),
        );
      }),
      // Bottom bar theo phong cách đã dùng
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border:
                const Border(top: BorderSide(color: Colors.black12, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showTraderForm(),
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text(
                    'Thêm lái',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====
  Widget _td(Widget child, {Alignment align = Alignment.centerLeft}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(alignment: align, child: child),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.black12),
            ),
          );
        },
      ),
    );
  }
}
