import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crab_purchase_controller.dart';
import '../../../controllers/crabtype_controller.dart';
import '../../../controllers/trader_controller.dart';
import '../../../models/trader_model.dart';
import '../../../widgets/touch_off_keyboard.dart';
import '../../../models/crabpurchase_model.dart' as purchaseModel;
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

  final List<TextEditingController> weightControllers = [];
  final List<bool> tareControllers = [];
  final List<double> originalWeights = [];
  final List<purchaseModel.CrabDetail> crabDetails = [];
  Trader? selectedTrader;
  final FocusNode weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeCrabDetails();
    // Đảm bảo rằng bàn phím không tự động bật lên khi trang này được dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _initializeCrabDetails() {
    crabTypeController.loadSelectedCrabTypesForToday();
    crabDetails.addAll(crabTypeController.selectedCrabTypes.map((crabType) {
      return purchaseModel.CrabDetail(
        crabType: crabType,
        weight: 0,
        pricePerKg: crabType.pricePerKg,
        totalCost: 0,
      );
    }).toList());
    weightControllers.clear();
    tareControllers.clear();
    originalWeights.clear();
    for (int i = 0; i < crabDetails.length; i++) {
      weightControllers.add(TextEditingController());
      tareControllers.add(false);
      originalWeights.add(0);
    }
  }

  @override
  void dispose() {
    for (var controller in weightControllers) {
      controller.dispose();
    }
    weightFocusNode.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      selectedTrader = null;
      crabDetails.clear();
      for (var controller in weightControllers) {
        controller.clear();
      }
      _initializeCrabDetails();
      FocusScope.of(context).unfocus();
    });
  }

  void _onSubmitInvoice() async {
    if (selectedTrader != null && crabDetails.isNotEmpty) {
      EasyLoading.show(status: 'Đang lưu hóa đơn...');
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

      // Gộp các loại cua cùng tên
      Map<String, purchaseModel.CrabDetail> mergedDetails = {};
      for (var detail in crabDetails) {
        if (mergedDetails.containsKey(detail.crabType.name)) {
          mergedDetails[detail.crabType.name]!.weight = double.parse(
              (mergedDetails[detail.crabType.name]!.weight + detail.weight)
                  .toStringAsFixed(2));
          mergedDetails[detail.crabType.name]!.totalCost = double.parse(
              (mergedDetails[detail.crabType.name]!.totalCost +
                      detail.totalCost)
                  .toStringAsFixed(2));
        } else {
          mergedDetails[detail.crabType.name] = purchaseModel.CrabDetail(
            crabType: detail.crabType,
            weight: detail.weight,
            pricePerKg: detail.pricePerKg,
            totalCost: detail.totalCost,
          );
        }
      }

      final List<purchaseModel.CrabDetail> finalCrabDetails =
          mergedDetails.values.toList();
      final double totalCost =
          finalCrabDetails.fold(0, (sum, item) => sum + item.totalCost);
      final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));

      final purchaseModel.CrabPurchase crabPurchase =
          purchaseModel.CrabPurchase(
        id: '',
        trader: selectedTrader!,
        crabs: finalCrabDetails,
        totalCost: totalCost,
        createdAt: now,
        updatedAt: now,
      );

      bool success =
          await crabPurchaseController.createCrabPurchase(crabPurchase);
      if (success) {
        _resetForm();

        final result =
            await Get.to(() => InvoicePdfView(crabPurchase: crabPurchase));
        if (result == true) {
          _resetForm(); // Ensure form is reset when coming back
        }
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

  void _addCrate(int index) {
    setState(() {
      final crabDetail = crabDetails[index];
      crabDetails.insert(
        index + 1,
        purchaseModel.CrabDetail(
          crabType: crabDetail.crabType,
          weight: 0,
          pricePerKg: crabDetail.pricePerKg,
          totalCost: 0,
        ),
      );
      weightControllers.insert(index + 1, TextEditingController());
      tareControllers.insert(index + 1, false);
      originalWeights.insert(index + 1, 0);
    });
  }

  void _toggleTare(int index) {
    setState(() {
      tareControllers[index] = !tareControllers[index];
      final double weight =
          double.tryParse(formatWeightInput(weightControllers[index].text)) ??
              0;
      if (tareControllers[index]) {
        originalWeights[index] = weight;
        crabDetails[index].weight =
            double.parse((weight - 2.8).toStringAsFixed(2));
      } else {
        crabDetails[index].weight = originalWeights[index];
      }
      crabDetails[index].totalCost =
          crabDetails[index].weight * crabDetails[index].pricePerKg;
      weightControllers[index].text = crabDetails[index].weight.toString();
    });
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
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.1),
                      3: FlexColumnWidth(1.9),
                      4: FlexColumnWidth(1.7),
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
                                  'Loại cua',
                                  style: TextStyle(
                                      fontSize: 20,
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
                                  'Số kí',
                                  style: TextStyle(
                                      fontSize: 20,
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
                                  'Giá',
                                  style: TextStyle(
                                      fontSize: 20,
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
                                  'Tổng',
                                  style: TextStyle(
                                      fontSize: 20,
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
                                  'Thêm',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...crabDetails.asMap().entries.map((entry) {
                        int index = entry.key;
                        purchaseModel.CrabDetail crabDetail = entry.value;
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    crabDetail.crabType.name,
                                    style: const TextStyle(
                                        fontSize: 20.25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: TextField(
                                    controller: weightControllers[index],
                                    decoration: const InputDecoration(
                                      labelStyle: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final double weight = double.tryParse(
                                              formatWeightInput(value)) ??
                                          0;
                                      setState(() {
                                        crabDetail.weight =
                                            tareControllers[index]
                                                ? double.parse((weight - 2.8)
                                                    .toStringAsFixed(2))
                                                : weight;
                                        originalWeights[index] =
                                            tareControllers[index]
                                                ? weight
                                                : originalWeights[index];
                                        crabDetail.totalCost =
                                            crabDetail.weight *
                                                crabDetail.pricePerKg;
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
                                    formatShortenNumberWithoutSymbol(
                                        crabDetail.pricePerKg),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 16),
                                child: Center(
                                  child: Text(
                                    formatNumberWithoutSymbol(
                                        crabDetail.totalCost),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_box,
                                        size: 30,
                                      ),
                                      onPressed: () => _addCrate(index),
                                    ),
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                        value: tareControllers[index],
                                        onChanged: (value) =>
                                            _toggleTare(index),
                                      ),
                                    ),
                                  ],
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
                        'Tổng cộng: ${formatCurrency(crabDetails.fold(0, (sum, item) => sum + item.totalCost))}',
                        style: const TextStyle(
                            fontSize: 19,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
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
