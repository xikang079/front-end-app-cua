import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/controllers/daily_summary_controller.dart';
import 'package:project_crab_front_end/models/dailysummary_model.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/auth_controller.dart';
import 'daily_summary_detail_view.dart';

class DailySummaryView extends StatelessWidget {
  final DailySummaryController controller = Get.put(DailySummaryController());
  final AuthController authController = Get.put(AuthController());

  DailySummaryView({super.key}) {
    controller.fetchAllDailySummariesByDepot();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final depotName = authController.user.value?.depotName ?? 'Tên vựa cua';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tổng hợp trong ngày'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAllDailySummariesByDepot,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.dailySummaries.isEmpty) {
            return const Center(child: Text('Không có báo cáo tổng hợp nào.'));
          }

          final Map<String, List<DailySummary>> summariesByMonth = {};
          for (var summary in controller.dailySummaries) {
            final monthKey =
                '${summary.createdAt.year}-${summary.createdAt.month.toString().padLeft(2, '0')}';
            if (summariesByMonth.containsKey(monthKey)) {
              summariesByMonth[monthKey]!.add(summary);
            } else {
              summariesByMonth[monthKey] = [summary];
            }
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: summariesByMonth.entries.map((entry) {
              final monthKey = entry.key;
              final monthSummaries = entry.value;
              return Card(
                elevation: 4,
                // margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Tháng: $monthKey',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: monthSummaries.map((summary) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Ngày: ${formatDate(summary.createdAt.toLocal())}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Tổng số tiền: ${formatCurrency(summary.totalAmount)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              controller.dailySummary.value = summary;
                              Get.to(() => DailySummaryDetailView(
                                    dailySummary: summary,
                                  ));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(
                                  color: Colors.grey, width: 2),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}
