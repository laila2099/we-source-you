import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/view/media_market/widgets/build_priceinput.dart';
import 'package:we_source_you/view/media_market/widgets/build_wrap.dart';
import '../media_market_controller/media_market_controller.dart';

class FilterDialog extends StatelessWidget {
  final Color activeColor = const Color(0xFFEF6666);
  final Color borderColor = const Color(0xFFE0E0E0);
  final MediaController controller;

  const FilterDialog({Key? key, required this.controller}) : super(key: key);

  // دالة مساعدة لإغلاق الكيبورد والنافذة بأمان
  void _closeDialog(BuildContext context) {
    // 1. إغلاق الكيبورد أولاً لتجنب خطأ العناصر
    FocusScope.of(context).unfocus();

    // 2. إغلاق النافذة
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector يساعد في إغلاق الكيبورد عند النقر في أي مكان فارغ
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 500,
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filter & Sort",
                      style: AppTextStyles.h4(
                        context,
                      ).copyWith(color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                      // استخدام الدالة الآمنة
                      onPressed: () => _closeDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),

              // --- Body ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Categories",
                        style: AppTextStyles.h4(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                      Obx(
                        () => buildWrapOptions(
                          controller,
                          controller.categoryOptions,
                          controller.filterCategories,
                          isMulti: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Price Range",
                        style: AppTextStyles.h4(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                      Row(
                        children: [
                          buildPriceInput(controller.minPriceController),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "-",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          buildPriceInput(controller.maxPriceController),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "License Type",
                        style: AppTextStyles.h4(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                      Obx(
                        () => buildWrapOptions(
                          controller,
                          controller.licenseOptions,
                          controller.filterLicense,
                          isMulti: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Media Type",
                        style: AppTextStyles.h4(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                      Obx(
                        () => buildWrapOptions(
                          controller,
                          controller.mediaTypeOptions,
                          controller.filterMediaType,
                          isMulti: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Sort By",
                        style: AppTextStyles.h4(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                      Obx(
                        () => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: controller.sortOptions.map((option) {
                            final isSelected =
                                controller.sortBy.value == option;
                            return InkWell(
                              onTap: () => controller.setSort(option),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeColor
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? activeColor
                                        : borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: borderColor),

              // --- Footer ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.clearFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Clear All",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        // استخدام الدالة الآمنة هنا أيضاً
                        onPressed: () => _closeDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
