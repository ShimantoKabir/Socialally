import 'dart:convert';

import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/MyLocation.dart';
import 'package:wengine/widgets/WelcomeNavBar.dart';
import 'package:wengine/utilities/HttpHandler.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:flutter/material.dart';

class Registration extends StatefulWidget {
  Registration({
    Key key,
    this.type,
    this.referrerId,
  }) : super(key: key);

  final int type;
  final String referrerId;

  @override
  RegistrationState createState() => RegistrationState(
    type: type,
    referrerId: referrerId
  );
}

class RegistrationState extends State<Registration> {

  int type;
  String referrerId;
  RegistrationState({
    Key key,
    this.type,
    this.referrerId
  });

  AlertDialog alertDialog;
  TextEditingController emailCtl = new TextEditingController();
  TextEditingController passwordCtl = new TextEditingController();
  TextEditingController confirmPasswordCtl = new TextEditingController();
  String regionName;
  String countryName;
  bool agreedTermsAndCondition;
  bool isLoading;
  Future futureLocations;
  MyLocation myLocation;

  @override
  void initState() {
    super.initState();
    regionName = "Select";
    countryName = "Select";
    agreedTermsAndCondition = false;
    isLoading = true;
    futureLocations = fetchLocations();
    myLocation = new MyLocation(
      countryName: "Select",
      regionName: null
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WelcomeNavBar(),
            Container(
              width: 500,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.05),
                  logo(),
                  Divider(
                    color: Colors.lightGreenAccent,
                    thickness: 1,
                  ),
                  SizedBox(height: 20),
                  emailPasswordWidget(),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text("Country",style: TextStyle(
                      fontWeight: FontWeight.bold
                    )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                    future: futureLocations,
                    builder: (context,snapshot){
                      if (snapshot.hasData) {
                        List<MyLocation> locations = snapshot.data;
                        if(locations.length > 0){

                          locations.forEach((loc) {
                            bool isValueExist = false;
                            locationDropDownList.forEach((drp) {
                              if(loc.countryName == drp.value.countryName){
                                isValueExist = true;
                              }
                            });
                            if(!isValueExist){
                              locationDropDownList.add(new DropdownMenuItem<MyLocation>(
                                value: MyLocation(
                                    regionName: loc.regionName,
                                    countryName: loc.countryName
                                ),
                                child: Text(loc.countryName),
                              ));
                            }
                          });

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: DropdownButton<MyLocation>(
                              value: myLocation,
                              isExpanded: true,
                              underline: SizedBox(),
                              onChanged: (MyLocation mln) {
                                setState(() {
                                  myLocation = MyLocation(
                                    regionName: mln.regionName,
                                    countryName: mln.countryName
                                  );
                                });
                              },
                              items: locationDropDownList
                            )
                          );
                        }else {
                          return Center(
                            child: Text("No notification found!"),
                          );
                        }
                      }else {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  ),
                  SizedBox(
                    height: 20,
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
                      Text('Terms and conditions.')
                    ],
                  ),
                  SizedBox(height: 20),
                  submitButton(context),
                  SizedBox(height: 20),
                  divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [facebookButton(), googleButton()],
                  ),
                  SizedBox(height: screenSize.height * .005),
                  createLoginLabel(),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget entryField(String title,TextEditingController ctl,bool isPassword) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: ctl,
            obscureText: isPassword,
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

  Widget submitButton(BuildContext buildContext) {
    return InkWell(
      onTap: () {
        bool isInputVerified = verifyInput(buildContext);
        if (isInputVerified) {
          var request = {
            "userInfo": {
              "email": emailCtl.text,
              "password": passwordCtl.text,
              "referredBy": referrerId,
              "type" : type,
              "countryName" : myLocation.countryName,
              "regionName" : myLocation.regionName,
              "agreedTermsAndCondition" : agreedTermsAndCondition
            },
            "clientUrl": Uri.base.origin
          };
          Alert.show(
              alertDialog, buildContext, Alert.LOADING, Alert.LOADING_MSG);
          HttpHandler().createPost("/users/registration", request).then((res) {
            Navigator.of(buildContext).pop(false);
            if (res.statusCode == 200) {
              if (res.data['code'] == 200) {
                Alert.show(
                    alertDialog, buildContext, Alert.SUCCESS, res.data['msg']);
              } else {
                Alert.show(
                    alertDialog, buildContext, Alert.ERROR, res.data['msg']);
              }
            } else {
              Alert.show(
                  alertDialog, buildContext, Alert.ERROR, Alert.ERROR_MSG);
            }
          }).catchError((err) {
            Navigator.of(buildContext).pop(false);
            Alert.show(alertDialog, buildContext, Alert.ERROR, Alert.ERROR_MSG);
          });
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2
            )
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.green, Colors.greenAccent]
          )
        ),
        child: Text(
          'Register',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or register with'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget facebookButton() {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  topLeft: Radius.circular(5)
                ),
              ),
              alignment: Alignment.center,
              child: Text('f',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400
                )
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(5),
                  topRight: Radius.circular(5)
                ),
              ),
              alignment: Alignment.center,
              child: Text('Facebook',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget googleButton() {
    return Container(
      height: 30,
      width: 120,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('G',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('Google',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  Widget logo() {
    return Center(
      child: Container(
        child: Text(type == 1 ? "User Registration" : "Admin Registration",
          style: TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }

  Widget emailPasswordWidget() {
    return Column(
      children: <Widget>[
        entryField("Email id", emailCtl, false),
        entryField("Password", passwordCtl,true),
        entryField("Confirm Password", confirmPasswordCtl, true)
      ],
    );
  }

  bool verifyInput(BuildContext buildContext) {
    bool isInputVerified = true;

    if (emailCtl.text.isEmpty) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Email required!");
      isInputVerified = false;
    } else if (!emailRegExp.hasMatch(emailCtl.text)) {
      Alert.show(alertDialog, buildContext, Alert.ERROR,
          "Email address format not correct!");
      isInputVerified = false;
    } else if (passwordCtl.text.isEmpty) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Password required!");
      isInputVerified = false;
    } else if (!passwordRegExp.hasMatch(passwordCtl.text)) {
      Alert.show(
          alertDialog,
          buildContext,
          Alert.ERROR,
          "Password should contain at least 8 character, "
          "one capital letter, one number and one special character!");
      isInputVerified = false;
    } else if (confirmPasswordCtl.text.isEmpty){
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Confirm password required!");
      isInputVerified = false;
    }else if (confirmPasswordCtl.text != passwordCtl.text){
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Password and confirm password did not matched!");
      isInputVerified = false;
    }else if (myLocation.countryName == "Select"){
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Please select a country!");
      isInputVerified = false;
    }else if (agreedTermsAndCondition == false){
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Please accept terms and conditions!");
      isInputVerified = false;
    }
    return isInputVerified;
  }

  Widget createLoginLabel() {
    return InkWell(
      onTap: () {
        if(type == 1){
          Navigator.pushNamed(context, "/user/login");
        }else {
          Navigator.pushNamed(context, "/admin/login");
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                color: Color(0xfff79c4f),
                fontSize: 13,
                fontWeight: FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }

  Future<List<MyLocation>> fetchLocations() async {

    List<MyLocation> locationList = [];

    if(locationDropDownList.isNotEmpty){
      locationDropDownList.clear();
    }

    locationDropDownList.add(new DropdownMenuItem<MyLocation>(
      value: MyLocation(
          regionName: null,
          countryName: "Select"
      ),
      child: Text("Select"),
    ));

    setState(() {
      myLocation = MyLocation(
        regionName: null,
        countryName: "Select"
      );
    });

    var response = await get("https://restcountries.eu/rest/v2/all");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> locations = jsonResponse;
      locations.asMap().forEach((key, location) {
        locationList.add(new MyLocation(
          countryName: location['name'],
          regionName: location['region']
        ));
      });
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }

    return locationList;

  }

}
