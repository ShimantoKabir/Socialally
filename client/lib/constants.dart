import 'package:client/models/ProjectCategory.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:google_fonts/google_fonts.dart';

EventHub eventHub = EventHub();

const kTextColor = Color(0xFF707070);
const kTextLightColor = Color(0xFF555555);
const kDefaultPadding = 20.0;
const baseUrl = "http://localhost:8000/api";
// const baseUrl = "http://workersengine.com/server/public/api";
// const baseUrl = "http://localhost/server/public";

const maxImageSize = 2097152;
const maxFileSize = 2097152;
List<String> allowedImageType = ["jpg","JPG","png","PNG"];
List<String> allowedFileType = ["pdf","docx"];
const oneMegaByte = 1048576;

final kDefaultShadow = BoxShadow(
  offset: Offset(0, 50),
  blurRadius: 50,
  color: Color(0xFF0700B1).withOpacity(0.15),
);

final kDefaultCardShadow = BoxShadow(
  offset: Offset(0, 20),
  blurRadius: 50,
  color: Colors.black.withOpacity(0.1),
);

final kDefaultInputDecorationTheme = InputDecorationTheme(
  border: kDefaultOutlineInputBorder,
  enabledBorder: kDefaultOutlineInputBorder,
  focusedBorder: kDefaultOutlineInputBorder,
);

final kDefaultOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Color(0xFFCEE4FD),
  ),
);

getThemeData(TextTheme textTheme) {
  return ThemeData(
    primarySwatch: Colors.green,
    textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
      bodyText1: GoogleFonts.armata(textStyle: textTheme.bodyText1),
    ),
  );
}

RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
RegExp passwordRegExp =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

List<Node> userDashboardMenus = [
  Node(
      label: 'Available Job',
      key: '/job/available',
      icon: NodeIcon.fromIconData(Icons.work_outline)),
  Node(
    label: 'Job',
    key: '/job/mine',
    icon: NodeIcon.fromIconData(Icons.work),
    children: [
      Node(
          label: 'Mine',
          key: '/job/mine',
          icon: NodeIcon.fromIconData(Icons.event_available)),
      Node(
          label: 'Post',
          key: '/job/post',
          icon: NodeIcon.fromIconData(Icons.event_available)),
      Node(
          label: 'Finished',
          key: '/job/finished',
          icon: NodeIcon.fromIconData(Icons.event_busy))
    ],
  ),
  Node(
      label: 'Deposit',
      key: '5',
      icon: NodeIcon.fromIconData(Icons.monetization_on)),
  Node(
      label: 'Wallet',
      key: '6',
      icon: NodeIcon.fromIconData(Icons.account_balance_wallet_outlined)),
  Node(
      label: 'Advertisement',
      key: '7',
      icon: NodeIcon.fromIconData(Icons.account_tree)),
  Node(
      label: 'Plan & Earn',
      key: '8',
      icon: NodeIcon.fromIconData(Icons.monetization_on_outlined)),
  Node(
      label: 'Support',
      key: '9',
      icon: NodeIcon.fromIconData(Icons.support)),
  Node(
      label: 'FAQ',
      key: '10',
      icon: NodeIcon.fromIconData(Icons.question_answer))
];

TreeViewTheme treeViewTheme = TreeViewTheme(
  expanderTheme: ExpanderThemeData(
    type: ExpanderType.caret,
    modifier: ExpanderModifier.none,
    position: ExpanderPosition.start,
    size: 20,
  ),
  labelStyle: TextStyle(
    fontSize: 16,
    letterSpacing: 0.3,
  ),
  parentLabelStyle: TextStyle(
    fontSize: 16,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w800,
  ),
  iconTheme: IconThemeData(
    size: 18,
    color: Colors.grey.shade800,
  ),
  colorScheme: ColorScheme.light(),
);

List<DropdownMenuItem<String>> regionDropDownList = [
  'Select',
  'Africa',
  'Americas',
  'Asia',
  'Europe',
  'Oceania'
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<String>> countryDropDownList = [
  'Select',
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<ProjectCategory>> projectCategoriesDropDownList = [
  ProjectCategory(
      id: 0, categoryId: 0, categoryName: "Select", subCategoryName: "Select")
].map<DropdownMenuItem<ProjectCategory>>((ProjectCategory projectCategory) {
  return DropdownMenuItem<ProjectCategory>(
    value: projectCategory,
    child: Text(projectCategory.categoryName),
  );
}).toList();

List<DropdownMenuItem<ProjectCategory>> projectSubCategoriesDropDownList = [
  ProjectCategory(
      id: 0, categoryId: 0, categoryName: "Select", subCategoryName: "Select")
].map<DropdownMenuItem<ProjectCategory>>((ProjectCategory projectCategory) {
  return DropdownMenuItem<ProjectCategory>(
    value: projectCategory,
    child: Text(projectCategory.categoryName),
  );
}).toList();
