import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ProjectCategory extends Equatable{
  int id;
  int categoryId;
  String categoryName;
  String subCategoryName;

  ProjectCategory(
      {this.id, this.categoryId, this.categoryName, this.subCategoryName});

  @override
  List<Object> get props => [id, categoryId, categoryName, subCategoryName];

  @override
  bool get stringify => false;
}
