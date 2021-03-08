import 'package:wengine/models/AdCostPlan.dart';
import 'package:wengine/models/ProjectCategory.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:google_fonts/google_fonts.dart';

EventHub eventHub = EventHub();

const kTextColor = Color(0xFF707070);
const kTextLightColor = Color(0xFF555555);
const kDefaultPadding = 20.0;
const baseUrl = "http://127.0.0.1:8000/api";
// const baseUrl = "https://workersengine.com/server/public/api";
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
    icon: NodeIcon.fromIconData(Icons.extension)
  ),
  Node(
    label: 'Job',
    key: '/job/mine',
    icon: NodeIcon.fromIconData(Icons.work),
    children: [
      Node(
        label: 'Post A New Job',
        key: '/job/post',
        icon: NodeIcon.fromIconData(Icons.post_add)
      ),
      Node(
        label: 'My Job',
        key: '/job/posted',
        icon: NodeIcon.fromIconData(Icons.event_available)
      ),
      Node(
        label: 'Applied',
        key: '/job/applied',
        icon: NodeIcon.fromIconData(Icons.pending_actions_sharp)
      )
    ],
  ),
  Node(
    label: 'Wallet',
    key: '/wallet',
    icon: NodeIcon.fromIconData(Icons.monetization_on),
    children: [
      Node(
        label: 'Deposit',
        key: '/wallet/deposit',
        icon: NodeIcon.fromIconData(Icons.arrow_downward_sharp),
      ),
      Node(
        label: 'Withdraw',
        key: '/wallet/withdraw',
        icon: NodeIcon.fromIconData(Icons.arrow_upward),
      ),
      Node(
        label: 'History',
        key: '/wallet/history',
        icon: NodeIcon.fromIconData(Icons.history),
      )
    ]
  ),
  // Node(
  //   label: 'Advertisement',
  //   key: '/advertisement',
  //   icon: NodeIcon.fromIconData(Icons.account_tree),
  //   children: [
  //     Node(
  //       label: 'Job',
  //       key: '/advertisement/job',
  //       icon: NodeIcon.fromIconData(Icons.send_to_mobile),
  //     ),
  //     Node(
  //       label: 'Advertised Job',
  //       key: '/advertisement/advertised/job',
  //       icon: NodeIcon.fromIconData(Icons.description),
  //     ),
  //     Node(
  //       label: 'Any',
  //       key: '/advertisement/any',
  //       icon: NodeIcon.fromIconData(Icons.mobile_screen_share_rounded),
  //     ),
  //     Node(
  //       label: 'Advertised Any',
  //       key: '/advertisement/advertised/any',
  //       icon: NodeIcon.fromIconData(Icons.mobile_friendly),
  //     )
  //   ]
  // ),
  Node(
      label: 'Profile',
      key: '/user/profile',
      icon: NodeIcon.fromIconData(Icons.account_circle_rounded),
      children: [
        Node(
          label: ' Update',
          key: '/user/profile/update',
          icon: NodeIcon.fromIconData(Icons.drive_file_rename_outline),
        ),
        Node(
          label: ' Change Password',
          key: '/user/profile/change-password',
          icon: NodeIcon.fromIconData(Icons.lock),
        ),
      ]
  ),
  Node(
      label: 'Advertisement',
      key: '/advertisement/any',
      icon: NodeIcon.fromIconData(Icons.account_tree)
  ),
  Node(
    label: 'Refer & Earn',
    key: '/refer-and-earn',
    icon: NodeIcon.fromIconData(Icons.monetization_on_outlined)
  ),
  Node(
    label: 'Support',
    key: '/support',
    icon: NodeIcon.fromIconData(Icons.support)
  )
];

List<Node> adminDashboardMenus = [
  Node(
    label: ' Dashboard',
    key: '/admin/dashboard',
    icon: NodeIcon.fromIconData(Icons.dashboard)
  ),
  Node(
    label: ' Setting',
    key: '/settings',
    icon: NodeIcon.fromIconData(Icons.settings),
    children: [
      Node(
          label: ' General',
          key: '/settings/general',
          icon: NodeIcon.fromIconData(Icons.settings_applications_rounded)
      ),
      Node(
          label: ' Advertisement Cost',
          key: '/settings/advertisement-cost',
          icon: NodeIcon.fromIconData(Icons.add_road_outlined)
      ),
      Node(
          label: ' Support Info',
          key: '/settings/support-info',
          icon: NodeIcon.fromIconData(Icons.support)
      ),
      Node(
          label: ' Payment Gateway',
          key: '/settings/payment-gateway',
          icon: NodeIcon.fromIconData(Icons.directions_off_sharp)
      )
    ],
  ),
  Node(
    label: ' Transaction',
    key: '/transaction',
    icon: NodeIcon.fromIconData(Icons.monetization_on_sharp),
    children: [
      Node(
        label: ' Requisition',
        key: '/transactions/requisition',
        icon: NodeIcon.fromIconData(Icons.request_page)
      )
    ],
  ),
  Node(
      label: ' Manage Job Category',
      key: '/categories/manage',
      icon: NodeIcon.fromIconData(Icons.category),
      children: [
        Node(
            label: ' Create Category',
            key: '/categories/create',
            icon: NodeIcon.fromIconData(Icons.workspaces_filled)
        ),
        Node(
            label: ' Create Sub Category',
            key: '/categories/create-sub-category',
            icon: NodeIcon.fromIconData(Icons.bar_chart)
        )
      ]
  ),
  Node(
      label: ' Send Notification',
      key: '/notifications/send',
      icon: NodeIcon.fromIconData(Icons.notifications_active)
  ),
  Node(
      label: ' Approve Job',
      key: '/job/approve',
      icon: NodeIcon.fromIconData(Icons.done_all)
  ),
  Node(
      label: ' Manage User',
      key: '/user/manage',
      icon: NodeIcon.fromIconData(Icons.people_outline)
  )
];

TreeViewTheme tvt = TreeViewTheme(
  expanderTheme: ExpanderThemeData(
    type: ExpanderType.caret,
    modifier: ExpanderModifier.none,
    position: ExpanderPosition.start,
    color: Colors.red.shade800,
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
    color: Colors.red.shade600,
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

List<DropdownMenuItem<String>> sortDropDownList = [
  'Select',
  'Less Paid',
  'Most Paid',
  'Finish Soon'
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<ProjectCategory>> projectCategoriesDropDownList = [
  ProjectCategory(
    id: 0,
    categoryId: 0,
    categoryName: "Select",
    subCategoryName: "Select"
  )
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

List<DropdownMenuItem<String>> paymentGatewayDropDownList = [
  'Select'
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<AdCostPlan>> adCostPlanDropDownList = [
  AdCostPlan(txt: "Select",day: 0,cost: 0)
].map<DropdownMenuItem<AdCostPlan>>((var plan) {
  return DropdownMenuItem<AdCostPlan>(
    value: plan,
    child: Text(plan.txt)
  );
}).toList();

List<DropdownMenuItem<String>> notificationForDropDownList = [
  'Select',
  'All',
  'Individual',
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<String>> jobApproveTypeDropDownList = [
  'Manual',
  'Automatic',
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

List<DropdownMenuItem<String>> referCommissionTypeDropDownList = [
  'Lifetime',
  'Limited',
].map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
  );
}).toList();

Widget showRequiredHeading(String title){
  return RichText(
    text: TextSpan(
      style: TextStyle(
          letterSpacing: 0.5,
          height: 1.5,
          color: Colors.black
      ),
      children: <TextSpan>[
        TextSpan(
          text: title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black
          )
        ),
        TextSpan(
          text: " *",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.red
          )
        )
      ],
    )
  );
}