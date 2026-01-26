enum ProjectStatus {
  pendingPayment,
  inProgress,
  underReview,
  completed,
  inDispute,
}

class ProjectModel {
  final String id;
  final double budget;
  ProjectStatus status;

  ProjectModel({
    required this.id,
    required this.budget,
    this.status = ProjectStatus.pendingPayment,
  });

  factory ProjectModel.empty() {
    return ProjectModel(
      id: '',
      budget: 0,
      status: ProjectStatus.pendingPayment,
    );
  }
}
