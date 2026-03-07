import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../apps/config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/confirm_dialog.dart';
import '../connectPrinterView/connect_printer_view.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final depotName = auth.user.value?.depotName ?? 'N/A';
    final address = auth.user.value?.address ?? 'N/A';
    final phone = auth.user.value?.phone ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
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
                  _sectionTitle('Thông tin vựa'),
                  _card(
                    child: Column(
                      children: [
                        _infoRow(
                          icon: Icons.account_box,
                          title: 'Tên vựa cua',
                          value: depotName,
                          multiline: false,
                        ),
                        const Divider(height: 0),
                        _infoRow(
                          icon: Icons.location_on,
                          title: 'Địa chỉ',
                          value: address,
                          multiline: true, // địa chỉ dài tự xuống dòng
                        ),
                        const Divider(height: 0),
                        _infoRow(
                          icon: Icons.phone,
                          title: 'Số điện thoại',
                          value: phone,
                          trailing: phone == 'N/A'
                              ? null
                              : IconButton(
                                  tooltip: 'Sao chép',
                                  icon: const Icon(Icons.copy,
                                      size: 20, color: AppColors.primaryColor),
                                  onPressed: () {
                                    Get.snackbar(
                                      'Đã sao chép',
                                      phone,
                                      backgroundColor: Colors.black87,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                    );
                                    // Clipboard.setData(ClipboardData(text: phone)); // nếu cần thực thi, import services
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle('Hành động'),
                  _card(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Get.to(() => const PrinterConnectionView()),
                            icon: const Icon(Icons.print,
                                color: AppColors.primaryColor),
                            label: const Text(
                              'Cài máy in',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primaryColor, width: 1.6),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  title: 'Xác nhận đăng xuất',
                                  content:
                                      'Bạn có chắc chắn muốn đăng xuất không?',
                                  onConfirm: () => auth.logout(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.red, width: 1.6),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====== Widgets con tái sử dụng theo phong cách 2 view trước ======

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
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

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    bool multiline = false,
    Widget? trailing,
  }) {
    final isNA = value.trim().isEmpty || value == 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // tiêu đề
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                // giá trị
                Text(
                  value,
                  softWrap: multiline,
                  overflow:
                      multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                  maxLines: multiline ? null : 1,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isNA ? Colors.black45 : AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing,
          ],
        ],
      ),
    );
  }
}
