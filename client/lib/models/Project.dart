class Project {
  final int id;
  final String title;
  final List<String> todoSteps;
  final List<String> requiredProofs;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final String regionName;
  final String countryName;
  final int workerNeeded;
  final int estimatedDay;
  final int estimatedCost;
  final String imageUrl;
  final String fileUrl;

  Project({
    this.id,
    this.title,
    this.todoSteps,
    this.requiredProofs,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.regionName,
    this.countryName,
    this.workerNeeded,
    this.estimatedDay,
    this.estimatedCost,
    this.imageUrl,
    this.fileUrl
  });
}
