import 'package:blue_thermal_printer/blue_thermal_printer.dart' as bt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/pages/user/crabPurchaseAndSummaryDailyView/crab_and_summary_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../crabPriceView/price_management_view.dart';
import '../dailySumView/daily_summary_view.dart';
import '../invoiceView/invoice_creation_view.dart';
import '../settingView/settings_view.dart';
import '../traderView/trader_management_view.dart';
import '../../../apps/config/app_colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0;
  final List<Widget> _pages = [
    const CrabTypeManagementView(),
    const TraderManagementView(),
    const InvoiceCreationView(),
    const CrabAndSummaryView(),
    SettingsView(),
  ];

  final bt.BlueThermalPrinter bluetooth = bt.BlueThermalPrinter.instance;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _autoConnectToPrinter();
  }

  void _autoConnectToPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceAddress = prefs.getString('device_address');

    if (deviceAddress != null) {
      List<bt.BluetoothDevice> devices = await bluetooth.getBondedDevices();
      bt.BluetoothDevice? device;
      try {
        device = devices.firstWhere(
          (d) => d.address == deviceAddress,
        );
      } catch (e) {
        device = null;
      }

      if (device != null) {
        // Kiểm tra nếu máy in đã được kết nối
        bool? isConnected = await bluetooth.isConnected;
        if (isConnected != null && isConnected) {
          setState(() {
            _isConnected = true;
          });
          Get.snackbar(
            'Thông báo',
            'Máy in đã được kết nối',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return;
        }

        try {
          await bluetooth.connect(device);
          setState(() {
            _isConnected = true;
          });
          Get.snackbar(
            'Thành công',
            'Tự động kết nối thành công với máy in',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          setState(() {
            _isConnected = false;
          });
          Get.snackbar(
            'Lỗi',
            'Không thể kết nối máy in tự động: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
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
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Loại cua',
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
