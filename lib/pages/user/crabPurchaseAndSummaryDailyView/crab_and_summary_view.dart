import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:project_crab_front_end/pages/user/crabPurchaseByDateView/crab_purchase_by_date_view.dart';
import 'package:project_crab_front_end/pages/user/dailySumView/daily_summary_view.dart';

class CrabAndSummaryView extends StatefulWidget {
  const CrabAndSummaryView({super.key});

  @override
  State<CrabAndSummaryView> createState() => _CrabAndSummaryViewState();
}

class _CrabAndSummaryViewState extends State<CrabAndSummaryView> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isScrollable = false;
    bool showNextIcon = true;
    bool showBackIcon = true;
    List<TabData> tabs = [
      TabData(
        index: 0,
        title: const Tab(
          child: Text(
            'Xem báo cáo theo ngày',
            style: TextStyle(fontSize: 19),
          ),
        ),
        content: DailySummaryView(),
      ),
      TabData(
        index: 1,
        title: const Tab(
          child: Text(
            'Xem hoá đơn theo ngày',
            style: TextStyle(fontSize: 19),
          ),
        ),
        content: const CrabPurchasesByDateView(),
      ),
      // Add more tabs as needed
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: DynamicTabBarWidget(
                dynamicTabs: tabs,
                isScrollable: isScrollable,
                onTabControllerUpdated: (controller) {},
                onTabChanged: (index) {
                  setState(() {
                    currentIndex = index!;
                  });
                },
                onAddTabMoveTo: MoveToTab.last,
                showBackIcon: showBackIcon,
                showNextIcon: showNextIcon,
                indicatorPadding: const EdgeInsets.all(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
