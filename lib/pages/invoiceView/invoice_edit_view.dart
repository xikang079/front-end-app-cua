// import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crab_purchase_controller.dart';
import '../../controllers/crabtype_controller.dart';
import '../../models/crabpurchase_model.dart';
import '../../models/crabtype_model.dart';
import '../../widgets/touch_off_keyboard.dart';

class EditInvoicePage extends StatefulWidget {
  final CrabPurchase crabPurchase;

  const EditInvoicePage({required this.crabPurchase, super.key});

  @override
  _EditInvoicePageState createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
  final CrabPurchaseController crabPurchaseController = Get.find();
  final CrabTypeController crabTypeController = Get.find();

  final List<CrabDetail> crabDetails = [];
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    crabTypeController.loadSelectedCrabTypesForToday();
    crabDetails.addAll(widget.crabPurchase.crabs);

    for (var crabType in crabTypeController.selectedCrabTypes) {
      if (crabDetails.indexWhere((crab) => crab.crabType.id == crabType.id) ==
          -1) {
        crabDetails.add(CrabDetail(
          crabType: crabType,
          weight: 0,
          pricePerKg: crabType.pricePerKg,
          totalCost: 0,
        ));
      }
    }

    for (var crabDetail in crabDetails) {
      controllers[crabDetail.crabType.id] = TextEditingController(
        text: crabDetail.weight > 0
            ? crabDetail.weight.toString().replaceAll('.', ',')
            : '',
      );
    }
  }

  void _onSubmitEdit() async {
    crabDetails.removeWhere((detail) => detail.weight == 0);

    if (crabDetails.isNotEmpty) {
      final double totalCost =
          crabDetails.fold(0, (sum, item) => sum + item.totalCost);
      final updatedCrabPurchase = CrabPurchase(
        id: widget.crabPurchase.id,
        trader: widget.crabPurchase.trader,
        crabs: crabDetails,
        totalCost: totalCost,
        createdAt: widget.crabPurchase.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = await crabPurchaseController.updateCrabPurchase(
          widget.crabPurchase.id, updatedCrabPurchase);

      if (success) {
        Get.snackbar(
          'Thành công',
          'Hóa đơn đã được cập nhật',
          backgroundColor: AppColors.snackBarSuccessColor,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Lỗi',
          'Cập nhật hóa đơn thất bại',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Lỗi',
        'Không có loại cua nào trong hóa đơn',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  String formatWeightInput(String input) {
    return input.replaceAll(',', '.');
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TouchOutsideToDismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Sửa hóa đơn', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thương nhân: ${widget.crabPurchase.trader.name}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.black54, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: const [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Tên loại cua',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Số kí (kg)',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Giá (VND/kg)',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Tổng tiền',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...crabDetails.map((crabDetail) {
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    crabDetail.crabType.name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(fontSize: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller:
                                        controllers[crabDetail.crabType.id],
                                    onChanged: (value) {
                                      final double weight = double.tryParse(
                                              formatWeightInput(value)) ??
                                          0;
                                      setState(() {
                                        crabDetail.weight = weight;
                                        crabDetail.totalCost =
                                            weight * crabDetail.pricePerKg;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    formatNumberWithoutSymbol(
                                        crabDetail.pricePerKg),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    formatNumberWithoutSymbol(
                                        crabDetail.totalCost),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng: ${formatCurrency(crabDetails.fold(0, (sum, item) => sum + item.totalCost))}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: _onSubmitEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customDropDownExampleCrabType(BuildContext context, CrabType? item) {
    if (item == null) {
      return Container();
    }

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        child: Text(
          item.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _customPopupItemBuilderExampleCrabType(
      BuildContext context, CrabType item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color:
            isSelected ? AppColors.accentColor.withOpacity(0.4) : Colors.white,
      ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            item.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
