import '../payments/contract_status.dart';

bool canClientPay(ContractStatus status) {
  return status == ContractStatus.paymentPending;
}

bool canFreelancerSubmit(ContractStatus status) {
  return status == ContractStatus.funded || status == ContractStatus.inProgress;
}

bool canClientApprove(ContractStatus status) {
  return status == ContractStatus.submitted;
}
