import 'package:client/models/ProjectCategory.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:google_fonts/google_fonts.dart';

EventHub eventHub = EventHub();

const kTextColor = Color(0xFF707070);
const kTextLightColor = Color(0xFF555555);
const kDefaultPadding = 20.0;
const baseUrl = "http://localhost:8000";

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
      bodyText1: GoogleFonts.montserrat(textStyle: textTheme.bodyText1),
    ),
  );
}

RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
RegExp passwordRegExp =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

List<Node> userDashboardMenus = [
  Node(label: 'Home', key: '0', icon: NodeIcon.fromIconData(Icons.home)),
  Node(
    label: 'Job',
    key: '1',
    icon: NodeIcon.fromIconData(Icons.work),
    children: [
      Node(
          label: 'Post',
          key: '2',
          icon: NodeIcon.fromIconData(Icons.event_available)),
      Node(
          label: 'Finished',
          key: '3',
          icon: NodeIcon.fromIconData(Icons.event_busy)),
      Node(
          label: 'Available',
          key: '4',
          icon: NodeIcon.fromIconData(Icons.post_add)),
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
  Node(label: 'Support', key: '9', icon: NodeIcon.fromIconData(Icons.support)),
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
