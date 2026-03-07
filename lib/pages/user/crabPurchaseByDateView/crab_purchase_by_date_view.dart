import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math' as math;

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crab_purchase_controller.dart';
import '../invoiceView/invoice_pdf_view.dart';

class CrabPurchasesByDateView extends StatefulWidget {
  const CrabPurchasesByDateView({super.key});

  @override
  State<CrabPurchasesByDateView> createState() =>
      _CrabPurchasesByDateViewState();
}

class _CrabPurchasesByDateViewState extends State<CrabPurchasesByDateView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final CrabPurchaseController c = Get.put(CrabPurchaseController());
  DateTime selectedDate = DateTime.now();

  // trạng thái các tile đang mở
  final Set<int> _expanded = {};

  // === responsive nhẹ (giảm upper clamp để chữ vừa vặn hơn)
  double _sx(BuildContext ctx) =>
      (MediaQuery.of(ctx).size.width / 430).clamp(1.0, 1.35);
  double _f(BuildContext ctx, double s) => (s * _sx(ctx)).clamp(13, 20);
  double _p(BuildContext ctx, double s) => (s * _sx(ctx)).clamp(4, 16);
  double _icon(BuildContext ctx, double s) => (s * _sx(ctx)).clamp(16, 24);

  @override
  void initState() {
    super.initState();
    c.fetchCrabPurchasesByDate(selectedDate);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      c.fetchCrabPurchasesByDate(selectedDate);
    }
  }

  void _goToday() {
    setState(() => selectedDate = DateTime.now());
    c.fetchCrabPurchasesByDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar giữ nguyên như bạn đã comment
      body: Column(
        children: [
          // ===== Header (ngày + thống kê)
          Padding(
            padding: EdgeInsets.all(_p(context, 5)),
            child: Container(
              padding: EdgeInsets.all(_p(context, 10)),
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
              child: Obx(() {
                final count = c.crabPurchases.length;
                final total = c.crabPurchases
                    .fold<double>(0, (sum, e) => sum + e.totalCost);
                return Wrap(
                  spacing: _p(context, 8),
                  runSpacing: _p(context, 8),
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _dateChip(
                      context,
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                    ),
                    _statChip(context, 'Số HĐ', '$count'),
                    _statChip(context, 'Tổng', formatCurrency(total),
                        accent: true),
                  ],
                );
              }),
            ),
          ),

          // ===== Dãy nút tác vụ
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _p(context, 10)),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(context),
                    icon: Icon(Icons.event,
                        size: _icon(context, 18),
                        color: AppColors.primaryColor),
                    label: Text('Chọn ngày',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: _f(context, 14),
                            fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primaryColor, width: 1.4),
                      padding: EdgeInsets.symmetric(vertical: _p(context, 9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: _p(context, 10)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _goToday,
                    icon: Icon(Icons.today,
                        size: _icon(context, 18), color: Colors.green[700]),
                    label: Text('Hôm nay',
                        style: TextStyle(
                            color: Colors.green[700],
                            fontSize: _f(context, 14),
                            fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.green.shade700, width: 1.4),
                      padding: EdgeInsets.symmetric(vertical: _p(context, 9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Danh sách hóa đơn
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.crabPurchases.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(_p(context, 16)),
                  child: _emptyState(
                      context, 'Không có hóa đơn nào cho ngày này.'),
                );
              }

              return AnimationLimiter(
                child: ListView.separated(
                  padding: EdgeInsets.all(_p(context, 10)),
                  itemCount: c.crabPurchases.length,
                  separatorBuilder: (_, __) => SizedBox(height: _p(context, 8)),
                  itemBuilder: (context, index) {
                    final item = c.crabPurchases[index];

                    return Container(
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
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.black12,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          key: PageStorageKey<String>('invoice_tile_$index'),
                          maintainState: true,
                          onExpansionChanged: (v) {
                            setState(() {
                              if (v) {
                                _expanded.add(index);
                              } else {
                                _expanded.remove(index);
                              }
                            });
                          },
                          tilePadding: EdgeInsets.symmetric(
                            horizontal: _p(context, 12),
                            vertical: _p(context, 6),
                          ),
                          childrenPadding: EdgeInsets.fromLTRB(
                            _p(context, 12),
                            0,
                            _p(context, 12),
                            _p(context, 12),
                          ),
                          title: Text(
                            item.trader.name,
                            style: TextStyle(
                              fontSize: _f(context, 14),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: _p(context, 2)),
                            child: Text(
                              'Tổng: ${formatCurrency(item.totalCost)}',
                              style: TextStyle(
                                fontSize: _f(context, 13),
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: _p(context, 10),
                                      vertical: _p(context, 6)),
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => Get.to(
                                    () => InvoicePdfView(crabPurchase: item)),
                                child: Text('In',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w800,
                                        fontSize: _f(context, 13))),
                              ),
                              SizedBox(width: _p(context, 6)),
                              AnimatedRotation(
                                turns: _expanded.contains(index) ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 180),
                                child: Icon(Icons.keyboard_arrow_right,
                                    size: _icon(context, 20),
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                          // Chi tiết hóa đơn
                          children: [
                            _invoiceDetailsTable(context, item, index),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          // ===== Footer tổng
          Obx(() {
            final total =
                c.crabPurchases.fold<double>(0, (sum, e) => sum + e.totalCost);
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                    top: BorderSide(color: Colors.black12, width: 1)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2))
                ],
              ),
              padding: EdgeInsets.fromLTRB(_p(context, 12), _p(context, 8),
                  _p(context, 12), _p(context, 12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tổng cộng mua: ${formatCurrency(total)}',
                      style: TextStyle(
                        fontSize: _f(context, 15),
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickDate(context),
                    icon: Icon(Icons.calendar_month,
                        size: _icon(context, 18),
                        color: AppColors.primaryColor),
                    label: Text('Đổi ngày',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: _f(context, 14))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primaryColor, width: 1.4),
                      padding: EdgeInsets.symmetric(
                          vertical: _p(context, 8),
                          horizontal: _p(context, 10)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ====== Sub-widgets ======

// Bảng chi tiết: KHÔNG override MediaQuery, khóa scale ngay trên Text
  Widget _invoiceDetailsTable(BuildContext context, dynamic item, int index) {
    final pad = _p(context, 10);
    final screenW = MediaQuery.of(context).size.width;
    final tableW = math.max(screenW - _p(context, 24), 720.0);

    String formatWeight(num value) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      } else {
        return value.toString();
      }
    }

    Widget cell(String text, {bool bold = false, bool right = false}) {
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: _p(context, 8)),
        child: Align(
          alignment: right ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: const TextScaler.linear(1.15),
            style: TextStyle(
              fontSize: _f(context, 16),
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ),
      );
    }

    const flex = [10, 20, 20, 20];

    Widget headerFixed() => Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(children: [
            Expanded(flex: flex[0], child: cell('Tên cua', bold: true)),
            Expanded(
                flex: flex[1],
                child: cell('Số kí (kg)', bold: true, right: true)),
            Expanded(
                flex: flex[2],
                child: cell('Giá VNĐ/kg', bold: true, right: true)),
            Expanded(
                flex: flex[3],
                child: cell('Tổng tiền', bold: true, right: true)),
          ]),
        );

    Widget row({
      required String name,
      required String weight,
      required String price,
      required String total,
      bool last = false,
    }) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: last
                ? BorderSide.none
                : const BorderSide(color: Colors.black12, width: 0.8),
          ),
        ),
        child: Row(children: [
          Expanded(flex: flex[0], child: cell(name)),
          Expanded(flex: flex[1], child: cell(weight, right: true)),
          Expanded(flex: flex[2], child: cell(price, right: true)),
          Expanded(flex: flex[3], child: cell(total, right: true)),
        ]),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: tableW,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                headerFixed(),
                ...List.generate(item.crabs.length, (i) {
                  final r = item.crabs[i];
                  return row(
                    name: r.crabType.name,
                    weight: formatWeight(r.weight),
                    price: formatNumberWithoutSymbol(r.pricePerKg),
                    total: formatNumberWithoutSymbol(r.totalCost),
                    last: i == item.crabs.length - 1,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateChip(BuildContext context, String dateText) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: EdgeInsets.symmetric(
          horizontal: _p(context, 10), vertical: _p(context, 6)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              size: _icon(context, 16), color: AppColors.primaryColor),
          SizedBox(width: _p(context, 6)),
          Text(dateText,
              style: TextStyle(
                  fontSize: _f(context, 13), fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value,
      {bool accent = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _p(context, 10), vertical: _p(context, 6)),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.primaryColor.withOpacity(0.07)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: accent ? AppColors.primaryColor : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                fontSize: _f(context, 13),
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.primaryColor : Colors.black87,
              )),
          Text(value,
              style: TextStyle(
                fontSize: _f(context, 13),
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.primaryColor : Colors.black87,
              )),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_p(context, 14)),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(message,
            style: TextStyle(
                fontSize: _f(context, 14), fontWeight: FontWeight.w700)),
      ),
    );
  }
}
