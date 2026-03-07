import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crabtype_controller.dart';
import '../../../models/dailysummary_model.dart';

class DailySummaryDetailView extends StatelessWidget {
  final DailySummary dailySummary;

  const DailySummaryDetailView({super.key, required this.dailySummary});

  // ------- responsive nhẹ giống các màn trước -------
  double _sx(BuildContext c) =>
      (MediaQuery.of(c).size.width / 430).clamp(1.0, 1.35);
  double _f(BuildContext c, double s) => (s * _sx(c)).clamp(13, 20);
  double _p(BuildContext c, double s) => (s * _sx(c)).clamp(4, 16);

  // Bỏ .0 khi là số nguyên, dùng dấu chấm cho thập phân
  String _fmtWeight(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    final nf = NumberFormat("0.###", "en_US"); // en_US => thập phân '.'
    return nf.format(v);
  }

  @override
  Widget build(BuildContext context) {
    final crabTypeController = Get.find<CrabTypeController>();

    final totalWeight =
        dailySummary.details.fold<double>(0, (s, d) => s + d.totalWeight);
    final estimatedCrates = (totalWeight / 24).round();

    // sắp xếp theo createdAt của CrabType
    final details = List<SummaryDetail>.from(dailySummary.details);
    details.sort((a, b) {
      final aDt = crabTypeController.crabTypes
          .firstWhere((t) => t.id == a.crabType)
          .createdAt;
      final bDt = crabTypeController.crabTypes
          .firstWhere((t) => t.id == b.crabType)
          .createdAt;
      return aDt.compareTo(bDt);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Báo cáo tổng hợp trong ngày',
          style: TextStyle(
              color: Colors.white,
              fontSize: _f(context, 16),
              fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_p(context, 10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------- Header info: MỖI THÔNG TIN 1 HÀNG ----------
            Container(
              padding: EdgeInsets.all(_p(context, 5)),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _kvRow(
                    context,
                    icon: Icons.event,
                    label: 'Ngày',
                    value:
                        DateFormat('dd/MM/yyyy').format(dailySummary.createdAt),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  _kvRow(
                    context,
                    icon: Icons.payments,
                    label: 'Tổng tiền',
                    value: formatCurrency(dailySummary.totalAmount),
                    accent: true,
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  _kvRow(
                    context,
                    icon: Icons.scale,
                    label: 'Tổng ký',
                    value: '${_fmtWeight(totalWeight)} kg',
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  _kvRow(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Số thùng khoảng',
                    value: '$estimatedCrates',
                  ),
                ],
              ),
            ),

            SizedBox(height: _p(context, 5)),

            // --------- Bảng ô kẻ rõ ràng ----------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Table(
                  border: const TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.black26, width: .9),
                    verticalInside:
                        BorderSide(color: Colors.black26, width: .9),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(15), // STT
                    1: FlexColumnWidth(25), // Loại cua
                    2: FlexColumnWidth(25), // Số ký
                    3: FlexColumnWidth(45), // Tổng tiền
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        _cellHeader(context, 'STT'),
                        _cellHeader(context, 'Loại cua'),
                        _cellHeader(context, 'Số kí (kg)'),
                        _cellHeader(context, 'Tổng tiền'),
                      ],
                    ),
                    ...details.asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      final name =
                          crabTypeController.getCrabTypeNameById(d.crabType);
                      return TableRow(
                        decoration: BoxDecoration(
                          color: i.isOdd ? Colors.grey[50] : Colors.white,
                        ),
                        children: [
                          _cell(context, (i + 1).toString()),
                          _cell(context, name),
                          _cell(context, _fmtWeight(d.totalWeight)),
                          _cell(context, formatCurrency(d.totalCost)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: _p(context, 50)),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Widget _kvRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      bool accent = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _p(context, 6), vertical: _p(context, 6)),
      child: Row(
        children: [
          Icon(icon,
              size: _f(context, 16),
              color: accent ? Colors.red : Colors.black54),
          SizedBox(width: _p(context, 8)),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: _f(context, 14),
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          // const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: _f(context, 15),
              fontWeight: FontWeight.w900,
              color: accent ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellHeader(BuildContext context, String text, {bool right = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _p(context, 12), vertical: _p(context, 10)),
      child: Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
              fontSize: _f(context, 14),
              fontWeight: FontWeight.w900,
              color: Colors.black87),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {bool right = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _p(context, 12), vertical: _p(context, 10)),
      child: Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
              fontSize: _f(context, 14),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.2),
        ),
      ),
    );
  }
}
