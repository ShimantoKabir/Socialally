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
  String countryName;
  int workerNeeded;
  int requiredScreenShots;
  int estimatedDay;
  int estimatedCost;
  String imageUrl;
  String fileUrl;
  int type;
  int proofSubmissionId;
  int totalApplied;
  String publisherName;
  String applicantName;
  String status;
  int publishedBy;
  int submittedBy;

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
    this.countryName,
    this.workerNeeded,
    this.requiredScreenShots,
    this.estimatedDay,
    this.estimatedCost,
    this.imageUrl,
    this.fileUrl,
    this.type,
    this.proofSubmissionId,
    this.totalApplied,
    this.publisherName,
    this.applicantName,
    this.status,
    this.publishedBy,
    this.submittedBy
  });
}
