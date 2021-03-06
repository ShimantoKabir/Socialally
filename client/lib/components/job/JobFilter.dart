import 'package:wengine/constants.dart';
import 'package:wengine/models/FilterCriteria.dart';
import 'package:wengine/models/ProjectCategory.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JobFilter extends StatefulWidget {

  JobFilter({
    Key key,
    this.type,
    this.eventHub,
    this.filterCriteria,
    this.userInfo
  }) : super(key: key);

  final type;
  final userInfo;
  final FilterCriteria filterCriteria;
  final EventHub eventHub;

  @override
  JobFilterState createState() => JobFilterState(
    key: key,
    type: type,
    userInfo: userInfo,
    filterCriteria: filterCriteria,
    eventHub: eventHub
  );
}

class JobFilterState extends State<JobFilter>{

  int type;
  var userInfo;
  EventHub eventHub;
  FilterCriteria filterCriteria;

  JobFilterState({
    Key key,
    this.type,
    this.userInfo,
    this.filterCriteria,
    this.eventHub,
  });

  ProjectCategory defaultProjectCategory;
  String regionName;
  String sortBy;
  TextEditingController searchTextCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    resetFilters();

    List<dynamic> projectCategories = userInfo['projectCategories'];
    projectCategories.asMap().forEach((key, projectCategory) {
      bool isValueExist = false;
      projectCategoriesDropDownList.forEach((element) {
        if (element.value.categoryName == projectCategory['categoryName']) {
          isValueExist = true;
        }
      });

      if (!isValueExist) {
        ProjectCategory pc = new ProjectCategory(
          id: null,
          subCategoryName: null,
          categoryId: projectCategory['categoryId'],
          categoryName: projectCategory['categoryName'],
        );

        projectCategoriesDropDownList.add(new DropdownMenuItem<ProjectCategory>(
          value: pc,
          child: Text(pc.categoryName),
        ));
      }
    });

    if(filterCriteria.categoryId != null){
      setState(() {
        defaultProjectCategory.categoryId = filterCriteria.categoryId;
        defaultProjectCategory.subCategoryName = null;
        defaultProjectCategory.id = null;
        defaultProjectCategory.categoryName = filterCriteria.categoryName;
      });
    }

    if(filterCriteria.location != null){
      setState(() {
        regionName = filterCriteria.location;
      });
    }

    if(filterCriteria.sortBy != null){
      setState(() {
        sortBy = filterCriteria.sortBy;
      });
    }

    if(filterCriteria.searchText != null){
      setState(() {
        searchTextCtl.text = filterCriteria.searchText;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blueGrey
                  )
                )
              ),
              child: Text(
                "FILTER",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Category"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
              child: DropdownButton<ProjectCategory>(
                value: defaultProjectCategory,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (ProjectCategory pc) {
                  setState(() {
                    defaultProjectCategory = new ProjectCategory(
                      id: pc.id,
                      categoryId: pc.categoryId,
                      categoryName: pc.categoryName,
                      subCategoryName: pc.subCategoryName
                    );
                  });
                },
                items: projectCategoriesDropDownList
              )
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Location"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
              child: DropdownButton<String>(
                value: regionName,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (String rn) {
                  setState(() {
                     regionName = rn;
                  });
                },
                items: regionDropDownList
              )
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("SortBy"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
              child: DropdownButton<String>(
                value: sortBy,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (String sb) {
                  setState(() {
                    sortBy = sb;
                  });
                },
                items: sortDropDownList
              )
            ),
            entryField("Search", searchTextCtl),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineButton(
                  onPressed: () {
                    eventHub.fire("redirectToAvailableJob",{
                      "filterCriteria" : FilterCriteria(
                        categoryName: defaultProjectCategory.categoryName ==
                          "Select" ?
                          null : defaultProjectCategory.categoryName,
                        categoryId:  defaultProjectCategory.categoryName ==
                            "Select" ?
                        null : defaultProjectCategory.categoryId,
                        location: regionName == "Select" ? null : regionName,
                        sortBy: sortBy == "Select" ? null : sortBy,
                        searchText: searchTextCtl.text,
                        type: type
                      )
                    });
                  },
                  child: Text("Submit")
                ),
                OutlineButton(
                  onPressed: () {
                    resetFilters();
                    clearFilterCriteria();
                    eventHub.fire("redirectToAvailableJob",{
                      "filterCriteria" : filterCriteria
                    });
                  },
                  child: Text("Reset")
                )
              ]
            )
          ],
        ),
      ),
    );
  }

  void resetFilters() {
    setState(() {
      defaultProjectCategory = ProjectCategory(
        id: 0,
        categoryId: 0,
        categoryName: "Select",
        subCategoryName: "Select"
      );
      regionName = "Select";
      sortBy = "Select";
      searchTextCtl.clear();
    });

  }

  clearFilterCriteria(){
    filterCriteria.type = type;
    filterCriteria.searchText = null;
    filterCriteria.sortBy = null;
    filterCriteria.location = null;
    filterCriteria.categoryId = null;
    filterCriteria.categoryName = null;
  }

  Widget entryField(String title, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true
            )
          )
        ],
      ),
    );
  }

}