import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_crab_front_end/widgets/touch_off_keyboard.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crab_purchase_controller.dart';
import '../../controllers/crabtype_controller.dart';
import '../../models/crabpurchase_model.dart';
import '../../models/crabtype_model.dart';

class EditInvoicePage extends StatefulWidget {
  final CrabPurchase crabPurchase;

  const EditInvoicePage({required this.crabPurchase, super.key});

  @override
  _EditInvoicePageState createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
  final CrabPurchaseController crabPurchaseController = Get.find();
  final CrabTypeController crabTypeController = Get.find();

  final TextEditingController weightController = TextEditingController();
  final List<CrabDetail> crabDetails = [];
  CrabType? selectedCrabType;

  @override
  void initState() {
    super.initState();
    crabDetails.addAll(widget.crabPurchase.crabs);
  }

  void _onAddCrabType() {
    if (selectedCrabType != null && weightController.text.isNotEmpty) {
      final double weight =
          double.parse(weightController.text.replaceAll(',', '.'));
      final double totalCost = weight * selectedCrabType!.pricePerKg;

      setState(() {
        crabDetails.add(CrabDetail(
          crabType: selectedCrabType!,
          weight: weight,
          pricePerKg: selectedCrabType!.pricePerKg,
          totalCost: totalCost,
        ));
        selectedCrabType = null;
      });

      weightController.clear();
    } else {
      Get.snackbar('Lỗi', 'Vui lòng chọn loại cua và nhập trọng lượng');
    }
  }

  void _onSubmitEdit() async {
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
              Obx(() {
                if (crabTypeController.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return SizedBox(
                  width: double.infinity,
                  child: DropdownSearch<CrabType>(
                    items: crabTypeController.crabTypes,
                    itemAsString: (CrabType crabType) => crabType.name,
                    selectedItem: selectedCrabType,
                    dropdownBuilder: _customDropDownExampleCrabType,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      itemBuilder: _customPopupItemBuilderExampleCrabType,
                    ),
                    onChanged: (CrabType? value) {
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
              TextField(
                controller: weightController,
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _onAddCrabType,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                        onPressed: _onSubmitEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          'Lưu',
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
