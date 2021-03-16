class Project {
  int id;
  String title;
  List<String> todoSteps;
  List<String> requiredProofs;
  List<String> givenProofs;
  List<String> givenScreenshotUrls;
  int categoryId;
  String categoryName;
  int subCategoryId;
  String subCategoryName;
  String regionName;
  List<String> countryNames;
  int workerNeeded;
  int requiredScreenShots;
  int estimatedDay;
  double estimatedCost;
  double eachWorkerEarn;
  String imageUrl;
  String fileUrl;
  int type;
  int proofSubmissionId;
  int totalApplied;
  String publisherName;
  String applicantName;
  String pfStatus;
  String status;
  int publishedBy;
  int submittedBy;
  String createdAt;

  Project({
    this.id,
    this.title,
    this.todoSteps,
    this.requiredProofs,
    this.givenProofs,
    this.givenScreenshotUrls,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.regionName,
    this.countryNames,
    this.workerNeeded,
    this.requiredScreenShots,
    this.estimatedDay,
    this.estimatedCost,
    this.eachWorkerEarn,
    this.imageUrl,
    this.fileUrl,
    this.type,
    this.proofSubmissionId,
    this.totalApplied,
    this.publisherName,
    this.applicantName,
    this.pfStatus,
    this.status,
    this.publishedBy,
    this.submittedBy,
    this.createdAt
  });
}
