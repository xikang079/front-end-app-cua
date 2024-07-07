import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/controllers/daily_summary_controller.dart';

import '../../apps/config/app_colors.dart';
import '../crabPriceView/price_management_view.dart';
import '../dailySumView/daily_summary_view.dart';
import '../invoiceView/invoice_creation_view.dart';
import '../settingView/settings_view.dart';
import '../traderView/trader_management_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0; // Default to the first page (Price Management)
  final DailySummaryController dailySummaryController =
      Get.find<DailySummaryController>();

  final List<Widget> _pages = [
    const PriceManagementView(),
    const TraderManagementView(),
    const InvoiceCreationView(),
    DailySummaryView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch the latest data when returning to HomeView
    ever<int>(dailySummaryController.dailySummaryIndex, (index) {
      if (_page == 3) {
        dailySummaryController.fetchAllDailySummariesByDepot();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
            // Không cần sử dụng Get.toNamed, chỉ cần cập nhật trang hiện tại
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Giá cua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Thương lái',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tạo hóa đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Tổng hợp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// home_view.dart
class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String heroTag;

  const AnimatedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.heroTag,
  });

  @override
  _AnimatedFloatingActionButtonState createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        heroTag: widget.heroTag, // Unique hero tag
        backgroundColor: AppColors.primaryColor,
        onPressed: widget.onPressed,
        child: const Icon(Icons.add, color: AppColors.buttonTextColor),
      ),
    );
  }
}
