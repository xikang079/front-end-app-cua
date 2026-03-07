import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/daily_summary_controller.dart';
import 'daily_summary_detail_view.dart';

class DailySummaryView extends StatelessWidget {
  final DailySummaryController controller = Get.put(DailySummaryController());
  DailySummaryView({super.key});

  // ========= Responsive helpers (nhẹ) =========
  double _sx(BuildContext c) =>
      (MediaQuery.of(c).size.width / 430).clamp(1.0, 1.35);
  double _f(BuildContext c, double s) => (s * _sx(c)).clamp(13, 20);
  double _p(BuildContext c, double s) => (s * _sx(c)).clamp(4, 16);
  double _icon(BuildContext c, double s) => (s * _sx(c)).clamp(16, 22);

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   toolbarHeight: _p(context, 44),
      //   backgroundColor: AppColors.primaryColor,
      //   title: Text(
      //     'Quản lí báo cáo cuối ngày',
      //     style: TextStyle(
      //         color: Colors.white,
      //         fontWeight: FontWeight.w800,
      //         fontSize: _f(context, 16)),
      //   ),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Tải lại',
      //       onPressed: () => controller.fetchDailySummariesByDepotAndMonth(
      //         controller.selectedMonth.value,
      //         controller.selectedYear.value,
      //       ),
      //       icon: Icon(Icons.refresh,
      //           color: Colors.white, size: _icon(context, 20)),
      //     ),
      //     SizedBox(width: _p(context, 4)),
      //   ],
      // ),

      // ================= BODY =================
      body: Column(
        children: [
          // ----- Bộ lọc Tháng/Năm -----
          Padding(
            padding: EdgeInsets.all(_p(context, 5)),
            child: Row(
              children: [
                Expanded(child: _monthPicker(context)),
                SizedBox(width: _p(context, 10)),
                Expanded(child: _yearPicker(context)),
              ],
            ),
          ),

          // ----- Danh sách -----
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return _shimmer(context);

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(_p(context, 16)),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                          fontSize: _f(context, 14),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }

              if (controller.dailySummaries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(_p(context, 16)),
                    child: Text(
                      'Không có báo cáo tổng hợp nào.',
                      style: TextStyle(
                          fontSize: _f(context, 14),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(_p(context, 10)),
                itemCount: controller.dailySummaries.length,
                separatorBuilder: (_, __) => SizedBox(height: _p(context, 8)),
                itemBuilder: (context, index) {
                  final s = controller.dailySummaries[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: _p(context, 12),
                        vertical: _p(context, 8),
                      ),
                      title: Text(
                        'Ngày: ${_d(s.createdAt)}',
                        style: TextStyle(
                            fontSize: _f(context, 16),
                            fontWeight: FontWeight.w800),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: _p(context, 2)),
                        child: Text(
                          'Tổng tiền mua: ${formatCurrency(s.totalAmount)}',
                          style: TextStyle(
                              fontSize: _f(context, 14),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      trailing: Wrap(
                        spacing: _p(context, 8),
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primaryColor, width: 1.4),
                              padding: EdgeInsets.symmetric(
                                vertical: _p(context, 6),
                                horizontal: _p(context, 8),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              controller.dailySummary.value = s;
                              Get.to(() =>
                                  DailySummaryDetailView(dailySummary: s));
                            },
                            child: Text(
                              'Truy cập',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: _f(context, 13),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.errorColor, width: 1.4),
                              padding: EdgeInsets.symmetric(
                                vertical: _p(context, 6),
                                horizontal: _p(context, 8),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final ok = await _confirmDelete(context);
                              if (ok) await controller.deleteDailySummary(s.id);
                            },
                            child: Text(
                              'Xóa',
                              style: TextStyle(
                                color: AppColors.errorColor,
                                fontSize: _f(context, 13),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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

  // ---------- Widgets con ----------

  Widget _monthPicker(BuildContext context) {
    return Obx(() {
      return DropdownButtonFormField<int>(
        value: controller.selectedMonth.value,
        decoration: InputDecoration(
          labelText: 'Tháng',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w700, fontSize: _f(context, 16)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: _p(context, 12), vertical: _p(context, 10)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: List.generate(12, (i) {
          final m = i + 1;
          return DropdownMenuItem(
              value: m,
              child: Text('Tháng $m',
                  style: TextStyle(fontSize: _f(context, 14))));
        }),
        onChanged: (v) {
          if (v != null && v != controller.selectedMonth.value) {
            controller.selectedMonth.value = v;
            controller.fetchDailySummariesByDepotAndMonth(
                v, controller.selectedYear.value);
          }
        },
      );
    });
  }

  Widget _yearPicker(BuildContext context) {
    return Obx(() {
      final currentYear = DateTime.now().year;
      return DropdownButtonFormField<int>(
        value: controller.selectedYear.value,
        decoration: InputDecoration(
          labelText: 'Năm',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w700, fontSize: _f(context, 16)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: _p(context, 12), vertical: _p(context, 10)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: List.generate(10, (i) {
          final y = currentYear - i;
          return DropdownMenuItem(
              value: y,
              child:
                  Text('Năm $y', style: TextStyle(fontSize: _f(context, 14))));
        }),
        onChanged: (v) {
          if (v != null && v != controller.selectedYear.value) {
            controller.selectedYear.value = v;
            controller.fetchDailySummariesByDepotAndMonth(
                controller.selectedMonth.value, v);
          }
        },
      );
    });
  }

  Widget _shimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: EdgeInsets.all(_p(context, 10)),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: _p(context, 8)),
        itemBuilder: (_, __) => Container(
          height: _p(context, 64),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Xác nhận',
                style: TextStyle(
                    fontSize: _f(context, 16), fontWeight: FontWeight.w800)),
            content: Text('Bạn có chắc chắn muốn xóa báo cáo này không?',
                style: TextStyle(fontSize: _f(context, 14))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy', style: TextStyle(fontSize: _f(context, 13))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xóa',
                    style: TextStyle(
                        color: AppColors.errorColor,
                        fontSize: _f(context, 13),
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
