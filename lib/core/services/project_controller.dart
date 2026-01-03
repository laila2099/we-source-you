import 'package:get/get.dart';
import 'package:we_source_you/model/project_model.dart';

class ProjectController extends GetxController {
  // جعل المشروع قابل للمراقبة (Observable)
  var project = ProjectModel(id: "PROJ-123", budget: 500.0).obs;
  var isLoading = false.obs;

  // 1. نظام شحن الرصيد (الدفع للمنصة)
  void payToPlatform() async {
    isLoading.value = true;
    // محاكاة عملية الدفع البنكي
    await Future.delayed(const Duration(seconds: 2));
    project.update((val) {
      val!.status = ProjectStatus.inProgress;
    });
    isLoading.value = false;
    Get.snackbar(
      "نجاح",
      "تم حجز المبلغ في خزنة المنصة، يمكن للمستقل البدء الآن",
    );
  }

  // 2. تسليم المشروع (من جهة المستقل)
  void submitProject() {
    project.update((val) {
      val!.status = ProjectStatus.underReview;
    });
    Get.snackbar("تنبيه", "تم تسليم العمل، بانتظار مراجعة صاحب المشروع");
  }

  // 3. قبول الاستلام (تحويل المال للمستقل)
  void approveAndReleaseFunds() {
    project.update((val) {
      val!.status = ProjectStatus.completed;
    });
    Get.snackbar("تم الإكمال", "تم تحويل المبلغ لحساب المستقل بنجاح");
  }

  // 4. فتح نزاع
  void openDispute() {
    project.update((val) {
      val!.status = ProjectStatus.inDispute;
    });
    Get.defaultDialog(
      title: "فتح نزاع",
      middleText: "سيتدخل الدعم الفني لمراجعة المحادثات والملفات.",
      textConfirm: "تأكيد",
      onConfirm: () => Get.back(),
    );
  }
}
