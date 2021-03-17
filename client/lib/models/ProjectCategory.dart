import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ProjectCategory extends Equatable{
  int id;
  int categoryId;
  String categoryName;
  String subCategoryName;
  double chargeByCategory;

  ProjectCategory({
    this.id,
    this.categoryId,
    this.categoryName,
    this.subCategoryName,
    this.chargeByCategory
  });

  @override
  List<Object> get props => [
    id,
    categoryId,
    categoryName,
    subCategoryName,
    chargeByCategory
  ];

  @override
  bool get stringify => false;
}
