import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/view/team/team_profile.dart';

Future<void> updateProposalStatus(String proposalId, String status) async {
  await FirebaseFirestore.instance
      .collection('proposals')
      .doc(proposalId)
      .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
}

Future<void> openTeamProfile(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('team')
        .doc(userId)
        .get();

    if (!doc.exists) {
      Get.snackbar('Error', 'Profile not found');
      return;
    }

    final member = TeamModel.fromMap(id: doc.id, map: doc.data()!);

    Get.to(() => TeamProfileView(member: member));
  } catch (e) {
    Get.snackbar('Error', 'Failed to load profile');
  }
}
