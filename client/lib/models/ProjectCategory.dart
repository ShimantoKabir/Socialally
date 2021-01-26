import 'package:equatable/equatable.dart';

class ProjectCategory extends Equatable{
  final int id;
  final int categoryId;
  final String categoryName;
  final String subCategoryName;

  ProjectCategory(
      {this.id, this.categoryId, this.categoryName, this.subCategoryName});

  @override
  List<Object> get props => [id, categoryId, categoryName, subCategoryName];

  @override
  bool get stringify => false;
}
