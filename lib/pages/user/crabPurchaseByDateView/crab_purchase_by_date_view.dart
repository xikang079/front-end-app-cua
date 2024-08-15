import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crab_purchase_controller.dart';
import '../invoiceView/invoice_pdf_view.dart';

class CrabPurchasesByDateView extends StatefulWidget {
  const CrabPurchasesByDateView({super.key});

  @override
  _CrabPurchasesByDateViewState createState() =>
      _CrabPurchasesByDateViewState();
}

class _CrabPurchasesByDateViewState extends State<CrabPurchasesByDateView> {
  final CrabPurchaseController _crabPurchaseController =
      Get.put(CrabPurchaseController());
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'), // Thêm locale để thay đổi ngôn ngữ
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Hóa đơn mua cua ngày ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: AppColors.primaryColor,
          toolbarHeight: 40,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
              },
            ),
          ]),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_crabPurchaseController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_crabPurchaseController.crabPurchases.isEmpty) {
                return const Center(
                    child: Text('Không có hóa đơn nào cho ngày này.'));
              }
              return AnimationLimiter(
                child: ListView.builder(
                  itemCount: _crabPurchaseController.crabPurchases.length,
                  itemBuilder: (context, index) {
                    final crabPurchase =
                        _crabPurchaseController.crabPurchases[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Column(
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[100],
                                margin: const EdgeInsets.all(8.0),
                                child: ExpansionTile(
                                  title: Text(
                                      'Thương lái: ${crabPurchase.trader.name}'),
                                  subtitle: Text(
                                      'Tổng số tiền: ${formatCurrency(crabPurchase.totalCost)}'),
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          DataTable(
                                            headingRowColor:
                                                WidgetStateColor.resolveWith(
                                                    (states) =>
                                                        Colors.grey[300]!),
                                            columns: const [
                                              DataColumn(
                                                  label: Text('Tên cua')),
                                              DataColumn(
                                                  label: Text('Số kí (kg)')),
                                              DataColumn(
                                                  label: Text('Giá VNĐ/kg')),
                                              DataColumn(
                                                  label: Text('Tổng tiền')),
                                            ],
                                            rows: crabPurchase.crabs
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              var crabDetail = entry.value;
                                              return DataRow(cells: [
                                                DataCell(Text(
                                                    crabDetail.crabType.name)),
                                                DataCell(Text(crabDetail.weight
                                                    .toString()
                                                    .replaceAll(',', '.'))),
                                                DataCell(Text(
                                                    formatNumberWithoutSymbol(
                                                        crabDetail
                                                            .pricePerKg))),
                                                DataCell(Text(
                                                    formatNumberWithoutSymbol(
                                                        crabDetail.totalCost))),
                                              ]);
                                            }).toList(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: ButtonBar(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    side: const BorderSide(
                                                      color: Colors.green,
                                                      width: 2,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                  ),
                                                  child: const Text(
                                                    'In',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Get.to(() => InvoicePdfView(
                                                        crabPurchase:
                                                            crabPurchase));
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  label: const Text(
                    'Chọn ngày',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey, width: 3),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
