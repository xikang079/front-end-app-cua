import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterDialog extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const PrinterDialog({super.key, required this.onDeviceSelected});

  @override
  _PrinterDialogState createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await bluetooth.connect(device);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_address', device.address!);

      widget.onDeviceSelected(device);
      Get.back();

      Get.snackbar(
        'Thành công',
        'Kết nối thành công với máy in',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối máy in: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn thiết bị máy in'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isConnecting
              ? const CircularProgressIndicator()
              : DropdownButton<BluetoothDevice>(
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _selectedDevice != null
              ? () => _connectToDevice(_selectedDevice!)
              : null,
          child: const Text('Kết nối'),
        ),
      ],
    );
  }
}
