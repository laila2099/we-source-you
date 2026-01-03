import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/services/project_controller.dart';
import 'package:we_source_you/model/project_model.dart';

class ProjectManagementPage extends StatelessWidget {
  final controller = Get.put(ProjectController());

  ProjectManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المشروع")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ), // حماية من التوسع الزائد في الويب
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            );
          }),
        ),
      ),
    );
  }

  // كرت حالة المشروع
  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "ميزانية المشروع: \$${controller.project.value.budget}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              "الحالة الحالية: ${controller.project.value.status.name.capitalizeFirst}",
            ),
          ],
        ),
      ),
    );
  }

  // أزرار العمليات (تظهر وتختفي حسب الحالة)
  Widget _buildActionButtons() {
    if (controller.isLoading.value) return const CircularProgressIndicator();

    switch (controller.project.value.status) {
      case ProjectStatus.pendingPayment:
        return ElevatedButton(
          onPressed: controller.payToPlatform,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text("دفع قيمة المشروع للخزنة (بدء العمل)"),
        );

      case ProjectStatus.inProgress:
        return Column(
          children: [
            const Text("المستقل يعمل الآن..."),
            ElevatedButton(
              onPressed: controller.submitProject,
              child: const Text("محاكاة: تسليم المستقل للعمل"),
            ),
          ],
        );

      case ProjectStatus.underReview:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: controller.approveAndReleaseFunds,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("قبول وتحويل المال"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: controller.openDispute,
                child: const Text("فتح نزاع / تعديلات"),
              ),
            ),
          ],
        );

      case ProjectStatus.completed:
        return const Text("✅ تمت العملية بنجاح وتم استلام المستقل لأتعابه");

      case ProjectStatus.inDispute:
        return const Text("⚖️ المشروع تحت مراجعة الدعم الفني");
    }
  }
}
