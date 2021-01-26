import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';
import 'package:client/utilities/HttpHandler.dart';
import 'package:client/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  Profile({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final EventHub eventHub;
  final userInfo;

  @override
  ProfileState createState() => ProfileState(key: key,eventHub: eventHub, userInfo: userInfo);
}

class ProfileState extends State<Profile>{

  EventHub eventHub;
  var userInfo;
  ProfileState({Key key, this.eventHub,this.userInfo});

  AlertDialog alertDialog;
  TextEditingController emailCtl = new TextEditingController();
  TextEditingController firstNameCtl = new TextEditingController();
  TextEditingController lastNameCtl = new TextEditingController();
  TextEditingController contactNumberCtl = new TextEditingController();
  TextEditingController passwordCtl = new TextEditingController();
  String regionName;
  String countryName;
  SharedPreferences preferences;
  bool agreedTermsAndCondition;
  bool wantNewsLetterNotification;

  @override
  void initState() {
    super.initState();

    emailCtl.text = userInfo['email'];
    firstNameCtl.text = userInfo['firstName'];
    lastNameCtl.text = userInfo['lastName'];
    contactNumberCtl.text = userInfo['contactNumber'];

    if(userInfo['regionName'] == null){
      regionName = "Select";
    }else {
      regionName = userInfo['regionName'];
    }

    if(userInfo['countryName'] == null){
      countryName = "Select";
    }else {
      countryName = userInfo['countryName'];
      countryDropDownList.add(new DropdownMenuItem<String>(
        value: userInfo['countryName'],
        child: Text(userInfo['countryName']),
      ));
    }

    if(userInfo['agreedTermsAndCondition'] == 0){
      agreedTermsAndCondition = false;
    }else {
      agreedTermsAndCondition = true;
    }

    if(userInfo['wantNewsLetterNotification'] == 0){
      wantNewsLetterNotification = false;
    }else {
      wantNewsLetterNotification = true;
    }

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: InkWell(
                        child: Container(
                          height: 150.0,
                          width: 150.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  "assets/images/people.png",
                                )),
                          ),
                        ),
                        onTap: () {
                        },
                      )),
                  InkWell(
                    onTap: () {},
                    child: Icon(Icons.camera_alt),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      readOnly: true,
                        controller: emailCtl,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            fillColor: Color(0xfff3f3f4),
                            filled: true))
                  ],
                ),
              ),
              entryField("First Name", firstNameCtl),
              entryField("Last Name", lastNameCtl),
              entryField("Contact Number", contactNumberCtl),
              entryField("Password", passwordCtl),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Region",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                        Radius.circular(5)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      15.0, 0.0, 0.0, 0.0),
                  child: DropdownButton<String>(
                      value: regionName,
                      isExpanded: true,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        fetchCountriesByRegion(context,newValue);
                      },
                      items: regionDropDownList
                  )),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "Country",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                        Radius.circular(5)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      15.0, 0.0, 0.0, 0.0),
                  child: DropdownButton<String>(
                      value: countryName,
                      isExpanded: true,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          countryName = newValue;
                        });
                      },
                      items: countryDropDownList
                  )),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Checkbox(
                    value: agreedTermsAndCondition,
                    onChanged: (value) {
                      setState(() {
                        agreedTermsAndCondition = value;
                      });
                    },
                  ),
                  Text('Agreed terms & condition')
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: wantNewsLetterNotification,
                    onChanged: (value) {
                      setState(() {
                        wantNewsLetterNotification = value;
                      });
                    },
                  ),
                  Text('Want news letter notification.')
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                      onPressed: (){
                        onSave(context);
                      },
                      child: Text("Save")
                  ),
                  OutlineButton(
                      onPressed: (){
                        onReset(context);
                      },
                      child: Text("Reset")
                  )
                ],
              )
            ],
          )
      )
    );
  }

  Widget entryField(String title,TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  bool verifyInput(BuildContext buildContext) {

    bool isInputVerified = true;
    String errMsg;

    if(firstNameCtl.text.isEmpty){
      userInfo['firstName'] = null;
    }else {
      userInfo['firstName'] = firstNameCtl.text;
    }

    if(lastNameCtl.text.isEmpty){
      userInfo['lastName'] = null;
    }else {
      userInfo['lastName'] = lastNameCtl.text;
    }

    if(contactNumberCtl.text.isEmpty){
      userInfo['contactNumber'] = null;
    }else {
      userInfo['contactNumber'] = contactNumberCtl.text;
    }

    if(passwordCtl.text.isEmpty){
      userInfo['password'] = null;
    }else {
      if (!passwordRegExp.hasMatch(passwordCtl.text)) {
        errMsg = "Password should contain at least 8 character, one capital letter, one number and one special character!";
        isInputVerified = false;
        userInfo['password'] = null;
      }else {
        userInfo['password'] = passwordCtl.text;
      }
    }

    if(regionName == "Select"){
      errMsg = "Please select a region!";
      isInputVerified = false;
    }else {
      userInfo['regionName'] = regionName;
    }

    if(countryName == "Select"){
      errMsg = "Please select a country!";
      isInputVerified = false;
    }else {
      userInfo['countryName'] = countryName;
    }

    if(agreedTermsAndCondition == false){
      errMsg = "Please agreed to terms & condition!";
      isInputVerified = false;
    }else {
      userInfo['agreedTermsAndCondition'] = 1;
    }

    if(wantNewsLetterNotification == false){
      userInfo['wantNewsLetterNotification'] = 0;
    }else {
      userInfo['wantNewsLetterNotification'] = 1;
    }

    if(!isInputVerified){
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }

    return isInputVerified;
  }

  Future<void> fetchCountriesByRegion(BuildContext context,String region) async {

    Alert.show(
        alertDialog, context, Alert.LOADING, Alert.LOADING_MSG);

    countryDropDownList.clear();

    countryDropDownList.add(new DropdownMenuItem<String>(
      value: "Select",
      child: Text("Select"),
    ));

    countryName = "Select";

    var response = await get("https://restcountries.eu/rest/v2/region/$region");
    if (response.statusCode == 200) {
      Navigator.of(context).pop(false);
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> countryNames = jsonResponse;
      countryNames.asMap().forEach((key, country) {
        countryDropDownList.add(new DropdownMenuItem<String>(
          value: country['name'],
          child: Text(country['name']),
        ));
      });
    } else {
      Alert.show(
          alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }

    setState(() {
      regionName = region;
    });

  }

  void onReset(BuildContext context) {

    firstNameCtl.clear();
    lastNameCtl.clear();
    contactNumberCtl.clear();
    passwordCtl.clear();

    setState(() {
      regionName = "Select";
      countryName = "Select";
      agreedTermsAndCondition = false;
      wantNewsLetterNotification = false;
    });

  }

  void onSave(BuildContext context) {

    bool isInputVerified = verifyInput(context);
    print("user info on save = $userInfo");

    if (isInputVerified) {
      var request = {
        "userInfo": userInfo
      };
      Alert.show(
          alertDialog, context, Alert.LOADING, Alert.LOADING_MSG);
      HttpHandler().createPut("/users", request).then((res) {
        Navigator.of(context).pop(false);
        if (res.statusCode == 200) {
          if (res.data['code'] == 200) {
            userInfo = res.data['userInfo'];
            MySharedPreferences.setStringValue('userInfo', jsonEncode(userInfo));
            eventHub.fire("userInfo",userInfo);
          } else {
            Alert.show(
                alertDialog, context, Alert.ERROR, res.data['msg']);
          }
        } else {
          Alert.show(
              alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      }).catchError((err) {
        Navigator.of(context).pop(false);
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      });
    }

  }

}