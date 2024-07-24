// views/invoice_creation_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crab_purchase_controller.dart';
import '../../controllers/crabtype_controller.dart';
import '../../controllers/trader_controller.dart';
import '../../models/crabpurchase_model.dart' as purchaseModel;
import '../../models/trader_model.dart';
import '../../widgets/touch_off_keyboard.dart';
import 'invoice_pdf_view.dart';

class InvoiceCreationView extends StatefulWidget {
  const InvoiceCreationView({super.key});

  @override
  _InvoiceCreationViewState createState() => _InvoiceCreationViewState();
}

class _InvoiceCreationViewState extends State<InvoiceCreationView> {
  final CrabPurchaseController crabPurchaseController =
      Get.put(CrabPurchaseController());
  final CrabTypeController crabTypeController = Get.put(CrabTypeController());
  final TraderController traderController = Get.put(TraderController());

  final TextEditingController weightController = TextEditingController();
  final List<purchaseModel.CrabDetail> crabDetails = [];
  Trader? selectedTrader;
  final FocusNode weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    crabTypeController.loadSelectedCrabTypesForToday();
    crabDetails.addAll(crabTypeController.selectedCrabTypes.map((crabType) {
      return purchaseModel.CrabDetail(
        crabType: crabType,
        weight: 0,
        pricePerKg: crabType.pricePerKg,
        totalCost: 0,
      );
    }).toList());
  }

  @override
  void dispose() {
    weightController.dispose();
    weightFocusNode.dispose();
    super.dispose();
  }

  void _onSubmitInvoice() async {
    if (selectedTrader != null && crabDetails.isNotEmpty) {
      EasyLoading.show(status: 'Đang lưu hóa đơn...');
      // Cập nhật lại danh sách crabDetails
      crabDetails.removeWhere((detail) => detail.weight == 0);

      if (crabDetails.isEmpty) {
        EasyLoading.dismiss();
        Get.snackbar(
          'Lỗi',
          'Vui lòng thêm loại cua có số kí lớn hơn 0',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
        return;
      }

      final double totalCost =
          crabDetails.fold(0, (sum, item) => sum + item.totalCost);

      final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));

      final purchaseModel.CrabPurchase crabPurchase =
          purchaseModel.CrabPurchase(
        id: '',
        trader: selectedTrader!,
        crabs: List<purchaseModel.CrabDetail>.from(crabDetails),
        totalCost: totalCost,
        createdAt: now,
        updatedAt: now,
      );

      bool success =
          await crabPurchaseController.createCrabPurchase(crabPurchase);
      if (success) {
        setState(() {
          selectedTrader = null;
          crabDetails.clear();
          weightController.clear();
          weightFocusNode.unfocus();
        });

        Get.to(() => InvoicePdfView(crabPurchase: crabPurchase));
      }
      EasyLoading.dismiss();
    } else {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn thương nhân và thêm loại cua',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                child: const ListTile(
                  title: Text(''),
                  subtitle: Text(''),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TouchOutsideToDismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Tạo hóa đơn', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          actions: [
            GestureDetector(
              onTap: () {
                Get.toNamed('/daily-invoices')!.then((_) {
                  crabTypeController.loadSelectedCrabTypesForToday();
                  setState(() {
                    crabDetails.clear();
                    crabDetails.addAll(
                      crabTypeController.selectedCrabTypes.map((crabType) {
                        return purchaseModel.CrabDetail(
                          crabType: crabType,
                          weight: 0,
                          pricePerKg: crabType.pricePerKg,
                          totalCost: 0,
                        );
                      }).toList(),
                    );
                  });
                });
              },
              child: const Row(
                children: [
                  Text("Xem Toa Trong Ngày:",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 5),
                  Icon(Icons.receipt, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Obx(() {
                if (traderController.isLoading.value) {
                  return _buildShimmerEffect();
                }
                return SizedBox(
                  width: double.infinity,
                  child: DropdownSearch<Trader>(
                    items: traderController.traders,
                    itemAsString: (Trader trader) => trader.name,
                    selectedItem: selectedTrader,
                    dropdownBuilder: _customDropDownExampleTrader,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      itemBuilder: _customPopupItemBuilderExampleTrader,
                    ),
                    onChanged: (Trader? value) {
                      setState(() {
                        selectedTrader = value;
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Chọn thương lái',
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                );
              }),
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
                    top: BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
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
                      TextButton.icon(
                        onPressed: _onSubmitInvoice,
                        icon: const Icon(Icons.save, color: Colors.green),
                        label: const Text(
                          'Lưu hóa đơn',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.grey, width: 3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
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

  Widget _customDropDownExampleTrader(BuildContext context, Trader? item) {
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

  Widget _customPopupItemBuilderExampleTrader(
      BuildContext context, Trader item, bool isSelected) {
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
