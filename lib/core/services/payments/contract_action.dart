import 'contract_service.dart';

class ContractActions {
  final ContractService _contractService;
  ContractActions(this._contractService);

  Future<void> freelancerSubmit({
    required String contractId,
    required String submissionType,
    required dynamic submissionData,
  }) {
    return _contractService.submitDelivery(
      contractId: contractId,
      submissionType: submissionType,
      submissionData: submissionData,
    );
  }

  Future<void> clientApprove({required String contractId}) {
    return _contractService.approveDelivery(contractId: contractId);
  }

  Future<void> freelancerConfirmClose({required String contractId}) {
    return _contractService.confirmClose(contractId: contractId);
  }
}
