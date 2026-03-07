import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../apps/config/app_colors.dart';

class PrinterConnectionView extends StatefulWidget {
  const PrinterConnectionView({super.key});

  @override
  State<PrinterConnectionView> createState() => _PrinterConnectionViewState();
}

class _PrinterConnectionViewState extends State<PrinterConnectionView> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = <BluetoothDevice>[];
  BluetoothDevice? _selectedDevice;

  bool _loadingDevices = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  static const _kSavedAddressKey = 'device_address';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getBondedDevices();
    await _restoreSavedSelectionAndConnect();
    await _refreshConnectionState();
  }

  Future<void> _getBondedDevices() async {
    setState(() => _loadingDevices = true);
    try {
      final list = await bluetooth.getBondedDevices();
      setState(() {
        _devices = list;
      });
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể lấy danh sách thiết bị: $e',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    } finally {
      setState(() => _loadingDevices = false);
    }
  }

  Future<void> _restoreSavedSelectionAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddr = prefs.getString(_kSavedAddressKey);
    if (savedAddr == null) return;

    final device = _devices.cast<BluetoothDevice?>().firstWhere(
          (d) => d?.address == savedAddr,
          orElse: () => null,
        );

    if (device != null) {
      setState(() => _selectedDevice = device);
      // chỉ auto-connect nếu hiện chưa kết nối
      final now = await bluetooth.isConnected;
      if (now != true) {
        await _connectToDevice(autoConnect: true);
      }
    }
  }

  Future<void> _refreshConnectionState() async {
    final state = await bluetooth.isConnected;
    setState(() => _isConnected = state == true);
  }

  Future<void> _connectToDevice({bool autoConnect = false}) async {
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

    final connected = await bluetooth.isConnected;
    if (connected == true) {
      if (!autoConnect) {
        Get.snackbar(
          'Thông báo',
          'Thiết bị đã kết nối',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
      setState(() => _isConnected = true);
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await bluetooth.connect(_selectedDevice!);
      final prefs = await SharedPreferences.getInstance();
      final address = _selectedDevice!.address;
      if (address != null) {
        await prefs.setString(_kSavedAddressKey, address);
      }
      setState(() => _isConnected = true);
      if (!autoConnect) {
        Get.snackbar(
          'Thành công',
          'Kết nối thành công với máy in',
          backgroundColor: AppColors.snackBarSuccessColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } catch (e) {
      setState(() => _isConnected = false);
      if (!autoConnect) {
        Get.snackbar(
          'Lỗi',
          'Không thể kết nối máy in: $e',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectFromDevice() async {
    try {
      await bluetooth.disconnect();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSavedAddressKey);
      setState(() => _isConnected = false);
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

  Future<void> _rescan() async {
    await _getBondedDevices();
    await _refreshConnectionState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title:
            const Text('Kết nối máy in', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            tooltip: 'Quét lại',
            onPressed: _rescan,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('Thiết bị'),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dropdown chọn thiết bị
                        _loadingDevices
                            ? _dropdownSkeleton()
                            : DropdownButtonFormField<BluetoothDevice>(
                                value: _selectedDevice,
                                decoration: const InputDecoration(
                                  labelText: 'Chọn thiết bị Bluetooth',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                icon: const Icon(Icons.arrow_drop_down),
                                items: _devices.map((d) {
                                  final name = (d.name ?? '').trim().isEmpty
                                      ? '(Không tên)'
                                      : d.name!;
                                  final addr = d.address ?? 'N/A';
                                  return DropdownMenuItem<BluetoothDevice>(
                                    value: d,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.print,
                                            color: AppColors.primaryColor,
                                            size: 22),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16)),
                                              Text(addr,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (d) =>
                                    setState(() => _selectedDevice = d),
                              ),
                        const SizedBox(height: 12),

                        // Hàng trạng thái + nút quét lại
                        Row(
                          children: [
                            _statusChip(_isConnected),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: _rescan,
                              icon: const Icon(Icons.search,
                                  color: AppColors.primaryColor),
                              label: const Text(
                                'Quét lại',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w900),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primaryColor, width: 1.6),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _sectionTitle('Kết nối'),
                  _card(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isConnecting
                                ? null
                                : (_isConnected
                                    ? _disconnectFromDevice
                                    : _connectToDevice),
                            icon: _isConnecting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(
                                    _isConnected ? Icons.link_off : Icons.link),
                            label: Text(
                              _isConnected ? 'Ngắt kết nối' : 'Kết nối',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isConnected
                                  ? Colors.red
                                  : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Gợi ý khi không thấy thiết bị
                  _hintCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers theo phong cách 2 view trước ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: child,
    );
  }

  Widget _statusChip(bool connected) {
    final color = connected ? Colors.green : Colors.red;
    final bg = connected ? Colors.green[50] : Colors.red[50];
    final text = connected ? 'Đã kết nối' : 'Chưa kết nối';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color[800],
        ),
      ),
    );
  }

  Widget _dropdownSkeleton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Đang tải danh sách thiết bị...'),
        ],
      ),
    );
  }

  Widget _hintCard() {
    return _card(
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nếu không thấy thiết bị:\n'
              '• Hãy chắc chắn máy in đã bật & ở chế độ ghép đôi (pairing)\n'
              '• Vào cài đặt Bluetooth của máy để Pair trước\n'
              '• Nhấn “Quét lại” để cập nhật danh sách',
              style: TextStyle(height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
