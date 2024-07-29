import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../apps/config/app_colors.dart';

class PrinterConnectionView extends StatefulWidget {
  const PrinterConnectionView({super.key});

  @override
  _PrinterConnectionViewState createState() => _PrinterConnectionViewState();
}

class _PrinterConnectionViewState extends State<PrinterConnectionView> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    _checkSavedConnection();
  }

  void _getBondedDevices() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể lấy danh sách thiết bị: $e',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  void _checkSavedConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceAddress = prefs.getString('device_address');

    if (deviceAddress != null) {
      BluetoothDevice? device;
      try {
        device = _devices.firstWhere(
          (d) => d.address == deviceAddress,
        );
      } catch (e) {
        device = null;
      }

      _selectedDevice = device;
      _connectToDevice(autoConnect: true);
    }
  }

  void _connectToDevice({bool autoConnect = false}) async {
    if (_selectedDevice == null) {
      if (!autoConnect) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn một thiết bị',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
      return;
    }

    final isConnected = await bluetooth.isConnected;
    if (isConnected!) {
      if (!autoConnect) {
        Get.snackbar(
          'Lỗi',
          'Thiết bị đã được kết nối',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      await bluetooth.connect(_selectedDevice!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_selectedDevice!.address != null) {
        await prefs.setString('device_address', _selectedDevice!.address!);
      }
      setState(() {
        _isConnected = true;
      });
      Get.snackbar(
        'Thành công',
        'Kết nối thành công với máy in',
        backgroundColor: AppColors.snackBarSuccessColor,
        colorText: AppColors.buttonTextColor,
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      if (!autoConnect) {
        Get.snackbar(
          'Lỗi',
          'Không thể kết nối máy in: $e',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _disconnectFromDevice() async {
    try {
      await bluetooth.disconnect();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_address');
      setState(() {
        _isConnected = false;
      });
      Get.snackbar(
        'Thành công',
        'Ngắt kết nối thành công',
        backgroundColor: AppColors.snackBarSuccessColor,
        colorText: AppColors.buttonTextColor,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể ngắt kết nối: $e',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Kết nối máy in', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              hint: const Text('Chọn thiết bị'),
              value: _selectedDevice,
              onChanged: (BluetoothDevice? device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _isConnecting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed:
                        _isConnected ? _disconnectFromDevice : _connectToDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isConnected ? Colors.red : Colors.green,
                    ),
                    child: Text(_isConnected ? 'Ngắt kết nối' : 'Kết nối'),
                  ),
          ],
        ),
      ),
    );
  }
}
