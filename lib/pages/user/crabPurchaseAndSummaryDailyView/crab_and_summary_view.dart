import 'package:flutter/material.dart';
import 'package:project_crab_front_end/pages/user/crabPurchaseByDateView/crab_purchase_by_date_view.dart';
import 'package:project_crab_front_end/pages/user/dailySumView/daily_summary_view.dart';

import '../../../apps/config/app_colors.dart';

class CrabAndSummaryView extends StatefulWidget {
  const CrabAndSummaryView({super.key});

  @override
  State<CrabAndSummaryView> createState() => _CrabAndSummaryViewState();
}

class _CrabAndSummaryViewState extends State<CrabAndSummaryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Không dùng AppBar ở đây vì mỗi tab con đã có AppBar riêng.
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          // KHÔNG dùng SingleChildScrollView ở tầng này để tránh unbounded height
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Thanh tab theo phong cách đồng bộ
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const TabBar(
                          isScrollable: false,
                          labelColor: AppColors.primaryColor,
                          unselectedLabelColor: Colors.black54,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          indicatorColor: AppColors.primaryColor,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: 'Xem báo cáo theo ngày'),
                            Tab(text: 'Xem hoá đơn theo ngày'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Khu vực nội dung tab PHẢI có ràng buộc chiều cao -> Expanded
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TabBarView(
                          // KHÔNG bọc SingleChildScrollView tại đây.
                          // Mỗi màn con (Scaffold) tự xử lý cuộn trong body của nó.
                          children: [
                            // 2 màn bên trong đều là Scaffold có AppBar riêng
                            DailySummaryView(),
                            const CrabPurchasesByDateView(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
