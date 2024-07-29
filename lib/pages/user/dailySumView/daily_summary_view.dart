import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/daily_summary_controller.dart';
import 'daily_summary_detail_view.dart';

class DailySummaryView extends StatelessWidget {
  final DailySummaryController controller = Get.put(DailySummaryController());

  DailySummaryView({super.key});

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text(
          'Quản lí báo cáo cuối ngày',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              controller.fetchDailySummariesByDepotAndMonth(
                  controller.selectedMonth.value,
                  controller.selectedYear.value);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return DropdownButton<int>(
                      value: controller.selectedMonth.value,
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('Tháng ${index + 1}'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null &&
                            value != controller.selectedMonth.value) {
                          controller.selectedMonth.value = value;
                          controller.fetchDailySummariesByDepotAndMonth(
                              value, controller.selectedYear.value);
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() {
                    return DropdownButton<int>(
                      value: controller.selectedYear.value,
                      items: List.generate(10, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text('Năm $year'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null &&
                            value != controller.selectedYear.value) {
                          controller.selectedYear.value = value;
                          controller.fetchDailySummariesByDepotAndMonth(
                              controller.selectedMonth.value, value);
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerEffect();
              }
              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }
              if (controller.dailySummaries.isEmpty) {
                return const Center(
                    child: Text('Không có báo cáo tổng hợp nào.'));
              }

              return MasonryGridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.dailySummaries.length,
                itemBuilder: (context, index) {
                  final summary = controller.dailySummaries[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    child: ListTile(
                      title: Text(
                        'Ngày: ${formatDate(summary.createdAt)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Tổng tiền mua: ${formatCurrency(summary.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: AppColors.errorColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 6),
                            ),
                            child: const Text('Xóa',
                                style: TextStyle(
                                    color: AppColors.errorColor, fontSize: 16)),
                            onPressed: () async {
                              bool confirmed =
                                  await _showConfirmationDialog(context);
                              if (confirmed) {
                                await controller.deleteDailySummary(summary.id);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: AppColors.primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 6),
                            ),
                            child: const Text('Truy cập',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16)),
                            onPressed: () {
                              controller.dailySummary.value = summary;
                              Get.to(() => DailySummaryDetailView(
                                  dailySummary: summary));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
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

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Xác nhận', style: TextStyle(fontSize: 20)),
              content: const Text(
                  'Bạn có chắc chắn muốn xóa báo cáo này không?',
                  style: TextStyle(fontSize: 18)),
              actions: [
                TextButton(
                  child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Xóa',
                      style:
                          TextStyle(color: AppColors.errorColor, fontSize: 16)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
