import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crab_purchase_controller.dart';
import '../../controllers/crabtype_controller.dart';
import '../../controllers/trader_controller.dart';
import '../../models/crabpurchase_model.dart' as purchaseModel;
import '../../models/crabtype_model.dart' as typeModel;
import '../../models/trader_model.dart';
import '../../widgets/touch_off_keyboard.dart';

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
  typeModel.CrabType? selectedCrabType;
  final FocusNode weightFocusNode = FocusNode();

  @override
  void dispose() {
    weightController.dispose();
    weightFocusNode.dispose();
    super.dispose();
  }

  void _onAddCrabType() {
    if (selectedCrabType != null && weightController.text.isNotEmpty) {
      final double weight =
          double.parse(weightController.text.replaceAll(',', '.'));
      final double totalCost = weight * selectedCrabType!.pricePerKg;

      setState(() {
        crabDetails.add(purchaseModel.CrabDetail(
          crabType: selectedCrabType!,
          weight: weight,
          pricePerKg: selectedCrabType!.pricePerKg,
          totalCost: totalCost,
        ));
        selectedCrabType = null;
      });

      weightController.clear();
      weightFocusNode.unfocus();
    } else {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn loại cua và nhập trọng lượng',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  void _onSubmitInvoice() async {
    if (selectedTrader != null && crabDetails.isNotEmpty) {
      final double totalCost =
          crabDetails.fold(0, (sum, item) => sum + item.totalCost);

      final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));

      final purchaseModel.CrabPurchase crabPurchase =
          purchaseModel.CrabPurchase(
        id: '',
        trader: selectedTrader!,
        crabs: crabDetails,
        totalCost: totalCost,
        createdAt: now,
        updatedAt: now,
      );

      bool success =
          await crabPurchaseController.createCrabPurchase(crabPurchase);
      if (success) {
        setState(() {
          selectedTrader = null;
          selectedCrabType = null;
          crabDetails.clear();
          weightController.clear();
          weightFocusNode.unfocus();
        });
      }
    } else {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn thương nhân và thêm loại cua',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
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
                Get.toNamed('/daily-invoices');
              },
              child: const Row(
                children: [
                  Text(
                    "Xem Toa Trong Ngày:",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.receipt,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Obx(() {
                if (traderController.isLoading.value) {
                  return const CircularProgressIndicator();
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
              Obx(() {
                if (crabTypeController.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return SizedBox(
                  width: double.infinity,
                  child: DropdownSearch<typeModel.CrabType>(
                    items: crabTypeController.crabTypes,
                    itemAsString: (typeModel.CrabType crabType) =>
                        crabType.name,
                    selectedItem: selectedCrabType,
                    dropdownBuilder: _customDropDownExampleCrabType,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      itemBuilder: _customPopupItemBuilderExampleCrabType,
                    ),
                    onChanged: (typeModel.CrabType? value) {
                      setState(() {
                        selectedCrabType = value;
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Chọn loại cua',
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16.0),
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    weightFocusNode.unfocus();
                  }
                },
                child: TextField(
                  controller: weightController,
                  focusNode: weightFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Trọng lượng (kg)',
                    labelStyle:
                        TextStyle(fontSize: 18, color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _onAddCrabType,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Thêm loại cua',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: crabDetails.length,
                  itemBuilder: (context, index) {
                    final crabDetail = crabDetails[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(crabDetail.crabType.name,
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.textColor)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số kí: ${crabDetail.weight} kg',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textColor),
                            ),
                            Text(
                              'Giá: ${formatCurrency(crabDetail.pricePerKg)}',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textColor),
                            ),
                            Text(
                              'Tổng: ${formatCurrency(crabDetail.totalCost)}',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textColor),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.errorColor),
                          onPressed: () {
                            setState(() {
                              crabDetails.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
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
                      ElevatedButton(
                        onPressed: _onSubmitInvoice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          'Tạo hóa đơn',
                          style: TextStyle(
                            color: Colors.white,
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

  Widget _customDropDownExampleCrabType(
      BuildContext context, typeModel.CrabType? item) {
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
      BuildContext context, typeModel.CrabType item, bool isSelected) {
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
