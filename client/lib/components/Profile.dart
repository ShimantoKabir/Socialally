import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:wengine/utilities/HttpHandler.dart';
import 'package:wengine/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  Profile({
    Key key,
    this.eventHub,
    this.userInfo,
    this.type
  }) : super(key: key);

  final EventHub eventHub;
  final userInfo;
  final type;

  @override
  ProfileState createState() =>
  ProfileState(
    key: key,
    eventHub: eventHub,
    userInfo: userInfo,
    type: type
  );
}

class ProfileState extends State<Profile> {
  EventHub eventHub;
  var userInfo;
  int type;

  ProfileState({
    Key key,
    this.eventHub,
    this.userInfo,
    this.type
  });

  AlertDialog alertDialog;
  TextEditingController emailCtl = new TextEditingController();
  TextEditingController firstNameCtl = new TextEditingController();
  TextEditingController lastNameCtl = new TextEditingController();
  TextEditingController contactNumberCtl = new TextEditingController();
  TextEditingController nationalIdCtl = new TextEditingController();
  TextEditingController passportIdCtl = new TextEditingController();
  TextEditingController userInfoIdCtl = new TextEditingController();
  String regionName;
  String countryName;
  SharedPreferences preferences;
  bool agreedTermsAndCondition;
  bool wantNewsLetterNotification;
  ImageProvider<Object> profileImageWidget;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;

  @override
  void initState() {
    super.initState();

    eventHub.fire("viewTitle", "Profile");

    userInfoIdCtl.text = userInfo['userInfoId'];
    emailCtl.text = userInfo['email'];
    firstNameCtl.text = userInfo['firstName'];
    lastNameCtl.text = userInfo['lastName'];
    nationalIdCtl.text = userInfo['nationalId'].toString();
    passportIdCtl.text = userInfo['passportId'].toString();
    contactNumberCtl.text = userInfo['contactNumber'].toString();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;

    if (userInfo['regionName'] == null) {
      regionName = "Select";
    } else {
      regionName = userInfo['regionName'];
    }

    if (userInfo['countryName'] == null) {
      countryName = "Select";
    } else {
      bool isValueExist = false;
      countryDropDownList.forEach((element) {
        if (element.value == userInfo['countryName']) {
          isValueExist = true;
        }
      });

      countryName = userInfo['countryName'];
      if (!isValueExist) {
        countryDropDownList.add(new DropdownMenuItem<String>(
          value: userInfo['countryName'],
          child: Text(userInfo['countryName']),
        ));
      }
    }

    if (userInfo['agreedTermsAndCondition'] == 0) {
      agreedTermsAndCondition = false;
    } else {
      agreedTermsAndCondition = true;
    }

    if (userInfo['wantNewsLetterNotification'] == 0) {
      wantNewsLetterNotification = false;
    } else {
      wantNewsLetterNotification = true;
    }

    if (userInfo['contactNumber'] == null) {
      contactNumberCtl.clear();
    }

    if (userInfo['nationalId'] == null) {
      nationalIdCtl.clear();
    }

    if (userInfo['passportId'] == null) {
      passportIdCtl.clear();
    }

    showProfilePic(userInfo);

  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
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
                                  fit: BoxFit.cover, image: profileImageWidget),
                            ),
                          ),
                          onTap: () {},
                        )),
                    InkWell(
                      onTap: () {
                        onProfilePicUpload(context);
                      },
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
                        "ID",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        readOnly: true,
                        controller: userInfoIdCtl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
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
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                entryField("First Name", firstNameCtl),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Last Name"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: lastNameCtl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Contact Number"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: contactNumberCtl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "National Id",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: nationalIdCtl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Passport Id",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passportIdCtl,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Region"),
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
                    onChanged: (String newValue) {
                      fetchCountriesByRegion(context, newValue);
                    },
                    items: regionDropDownList
                  )
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Country"),
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
                    value: countryName,
                    isExpanded: true,
                    underline: SizedBox(),
                    onChanged: (String newValue) {
                      setState(() {
                        countryName = newValue;
                      });
                    },
                    items: countryDropDownList
                  )
                ),
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
                    Text('Terms and conditions.'),
                    Text(
                      ' * ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
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
                Visibility(
                  visible: type == null ? true : false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                          onPressed: () {
                            bool isInputVerified = verifyInput(context);
                            if (isInputVerified) {
                              onSave(context);
                            }
                          },
                          child: Text("Save")
                      ),
                      OutlineButton(
                          onPressed: () {
                            onReset(context);
                          },
                          child: Text("Reset")
                      )
                    ],
                  )
                )
              ]
            )
          )
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        )
      )
    );
  }

  Widget entryField(String title, TextEditingController controller) {
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

    if (firstNameCtl.text.isEmpty) {
      userInfo['firstName'] = null;
    } else {
      userInfo['firstName'] = firstNameCtl.text;
    }

    if (lastNameCtl.text.isEmpty) {
      userInfo['lastName'] = null;
      isInputVerified = false;
      errMsg = "Last name required!";
    } else {
      userInfo['lastName'] = lastNameCtl.text;
    }

    if (contactNumberCtl.text.isEmpty) {
      userInfo['contactNumber'] = null;
      isInputVerified = false;
      errMsg = "Contact number required!";
    } else {
      userInfo['contactNumber'] = contactNumberCtl.text;
    }

    if (passportIdCtl.text.isEmpty) {
      userInfo['passportId'] = null;
    } else {
      userInfo['passportId'] = passportIdCtl.text;
    }

    if (nationalIdCtl.text.isEmpty) {
      userInfo['nationalId'] = null;
    } else {
      userInfo['nationalId'] = nationalIdCtl.text;
    }

    if (regionName == "Select") {
      errMsg = "Please select a region!";
      isInputVerified = false;
    } else {
      userInfo['regionName'] = regionName;
    }

    if (countryName == "Select") {
      errMsg = "Please select a country!";
      isInputVerified = false;
    } else {
      userInfo['countryName'] = countryName;
    }

    if (agreedTermsAndCondition == false) {
      errMsg = "Please agreed to terms & condition!";
      isInputVerified = false;
    } else {
      userInfo['agreedTermsAndCondition'] = 1;
    }

    if (wantNewsLetterNotification == false) {
      userInfo['wantNewsLetterNotification'] = 0;
    } else {
      userInfo['wantNewsLetterNotification'] = 1;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, errMsg);
    }
    return isInputVerified;
  }

  Future<void> fetchCountriesByRegion(
      BuildContext context, String region) async {

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    countryDropDownList.clear();

    countryDropDownList.add(new DropdownMenuItem<String>(
      value: "Select",
      child: Text("Select"),
    ));

    countryName = "Select";

    var response = await get("https://restcountries.eu/rest/v2/region/$region");
    setState(() {
      needToFreezeUi = false;
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> countryNames = jsonResponse;
      countryNames.asMap().forEach((key, country) {
        countryDropDownList.add(new DropdownMenuItem<String>(
          value: country['name'],
          child: Text(country['name']),
        ));
      });
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    setState(() {
      regionName = region;
    });
  }

  void onReset(BuildContext context) {
    firstNameCtl.clear();
    lastNameCtl.clear();
    contactNumberCtl.clear();

    setState(() {
      regionName = "Select";
      countryName = "Select";
      agreedTermsAndCondition = false;
      wantNewsLetterNotification = false;
    });
  }

  void onSave(BuildContext context) {

    var request = {"userInfo": userInfo};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    HttpHandler().createPut("/users", request).then((res) {
      setState(() {
        needToFreezeUi = false;
      });
      if (res.statusCode == 200) {
        if (res.data['code'] == 200) {
          Alert.show(alertDialog, context, Alert.SUCCESS, res.data['msg']);
          userInfo = res.data['userInfo'];
          MySharedPreferences.setStringValue(
              'userInfo', jsonEncode(userInfo));
          eventHub.fire("userInfo", userInfo);
          setState(() {
            showProfilePic(userInfo);
          });
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, res.data['msg']);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });
  }

  Future<void> onProfilePicUpload(BuildContext context) async {

    String base64String;

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedImageType,
    );

    if (result != null) {
      PlatformFile objFile = result.files.single;

      if (Platform.isAndroid || Platform.isIOS) {
        base64String = base64.encode(File(objFile.path).readAsBytesSync());
      } else {
        base64String = base64.encode(objFile.bytes);
      }

      if (objFile.size > maxImageSize) {
        Alert.show(
            alertDialog,
            context,
            Alert.ERROR,
            "Image size cross the max limit, "
            "You can only upload ${maxImageSize / oneMegaByte} or "
                "less then ${maxImageSize / oneMegaByte} mb image.");
      } else {

        setState(() {
          needToFreezeUi = true;
          alertIcon = Alert.showIcon(Alert.LOADING);
          alertText = Alert.LOADING_MSG;
        });

        String url = baseUrl + '/users/image';
        Map<String, String> headers = {"Content-type": "application/json"};
        var request = {
          'userInfo': {
            'id': userInfo['id'],
            'imageString': base64String,
            'fileExt': objFile.extension
          }
        };

        Response response =
            await post(url, headers: headers, body: json.encode(request));

        setState(() {
          needToFreezeUi = false;
        });

        if (response.statusCode == 200) {
          var body = json.decode(response.body);

          if (body['code'] == 200) {
            Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
            String imageUrl = body['userInfo']["imageUrl"];
            userInfo["imageUrl"] = imageUrl;
            MySharedPreferences.setStringValue(
                'userInfo', jsonEncode(userInfo));
            eventHub.fire("userInfo", userInfo);

            setState(() {
              profileImageWidget = NetworkImage(imageUrl);
            });
          } else {
            Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
          }
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      }
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "No file selected!");
    }
  }

  void showProfilePic(userInfo) {
    if (userInfo['imageUrl'] == null) {
      profileImageWidget = AssetImage("assets/images/dummy_user_image.png");
    } else {
      profileImageWidget = NetworkImage(userInfo['imageUrl']);
    }
  }
}
