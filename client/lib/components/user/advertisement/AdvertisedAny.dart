import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialally/constants.dart';
import 'package:socialally/models/Advertisement.dart';
import 'package:socialally/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvertisedAny extends StatefulWidget {
  AdvertisedAny({Key key, this.eventHub, this.userInfo, this.type}) : super(key: key);
  final EventHub eventHub;
  final userInfo;
  final type;

  @override
  AdvertisedAnyState createState() =>
      AdvertisedAnyState(key: key, eventHub: eventHub, userInfo: userInfo,type: type);
}

class AdvertisedAnyState extends State<AdvertisedAny> {
  EventHub eventHub;
  var userInfo;
  int type;
  AdvertisedAnyState({Key key, this.eventHub, this.userInfo, this.type});

  AlertDialog alertDialog;
  Future futureAdvertisedAny;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 3;
  int pageNumber = 0;
  ScrollController scrollController = ScrollController();
  IconButton scrollButton;
  IconButton nextButton;
  IconButton previousButton;
  bool isTappedToImage = false;
  int scrollCompletionCounter = 0;
  Timer timer;

  @override
  void initState() {

    if(type == 2){
      eventHub.fire("viewTitle","Advertised Any");
    }
    futureAdvertisedAny = fetchAdvertisedAny();
    alertText = "No operation running!";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;

    scrollButton = IconButton(
      icon: Icon(
        Icons.keyboard_arrow_down
      ),
      onPressed: (){
        if(scrollController.hasClients){
          scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 10000),
              curve: Curves.ease
          ).whenComplete((){
            scrollCompletionCounter++;
            if(scrollController.hasClients){
              scrollController.animateTo(
                  scrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 10000),
                  curve: Curves.ease
              ).whenComplete((){
                scrollCompletionCounter++;
              });
            }
          });
        }
      }
    );

    nextButton = IconButton(
      icon: Icon(
        Icons.arrow_forward_ios,
        size: 15
      ),
      onPressed: (){
        pageIndex = pageIndex + perPage;
        needToFreezeUi = true;
        pageNumber++;
        setState(() {
          futureAdvertisedAny = fetchAdvertisedAny();
        });
      }
    );

    previousButton = IconButton(
      icon: Icon(
          Icons.arrow_back_ios,
          size: 15
      ),
      onPressed: (){
        if(pageIndex < 1){
          Alert.show(alertDialog, context, Alert.ERROR, "You are already in the first page!");
        }else {
          pageNumber--;
          pageIndex = pageIndex - perPage;
          needToFreezeUi = true;
          setState(() {
            futureAdvertisedAny = fetchAdvertisedAny();
          });
        }
      }
    );

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
       if(isTappedToImage){
         isTappedToImage = false;
         scrollButton.onPressed();
       }

       if(scrollCompletionCounter >= 2){
         scrollCompletionCounter = 0;
         scrollButton.onPressed();
       }
    });

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: futureAdvertisedAny,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Advertisement> advertisements = snapshot.data;
            if(advertisements.length == 0){
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Text(
                    "No advertisement found!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                    ),
                  )
                ),
              );
            }else {
              Future.delayed(Duration(days: 0,hours: 0,seconds: 10), () async {
                try {
                  if(advertisements.length >= 3 && type == 1){
                    scrollButton.onPressed();
                  }
                }catch (error) {
                  print("er $error");
                }
              });
              return ListView.builder(
                  controller: scrollController,
                  itemCount: advertisements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(10,5,10,5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    advertisements[index].title,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15
                                    ),
                                  ),
                                  Visibility(
                                    child: Text(
                                      advertisements[index].status,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: advertisements[index].status == "Pending" ?
                                          Colors.blue : advertisements[index].status == "Approved" ?
                                          Colors.green : Colors.red
                                      ),
                                    ),
                                    visible: type != 1,
                                  )
                                ],
                              ),
                              decoration: headingDecoration(),
                            ),
                            SizedBox(height: 5),
                            InkWell(
                                child: CachedNetworkImage(
                                  width: 300,
                                  height: 190,
                                  imageUrl: advertisements[index].bannerImageUrl,
                                  placeholder: (context, url) => Center(
                                    child: Padding(
                                      child: CircularProgressIndicator(),
                                      padding: EdgeInsets.all(20),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                onTap: (){
                                  isTappedToImage = true;
                                  openUrl(advertisements[index].targetedDestinationUrl, context);
                                }
                            ),
                            Visibility(
                                visible: type == 3,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10,10,10,0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Duration ${advertisements[index].adDuration} Day, Cost ${advertisements[index].adCost}"),
                                      Row(
                                        children: [
                                          OutlineButton(
                                            onPressed: (){
                                              onUpdate(
                                                  context,
                                                  advertisements[index],
                                                  "Approved"
                                              );
                                            },
                                            child: Text("Approve"),
                                          ),
                                          SizedBox(width: 5),
                                          OutlineButton(
                                            onPressed: (){
                                              onUpdate(
                                                  context,
                                                  advertisements[index],
                                                  "Declined"
                                              );
                                            },
                                            child: Text("Declined"),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    );
                  }
              );
            }
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: needToFreezeUi,
        child: Container(
          color: Colors.black12,
          height: 50.0,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              scrollButton,
              Visibility(
                visible: needToFreezeUi,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 2,
                  ),
                )
              ),
              Visibility(
                child: Row(
                  children: [
                    previousButton,
                    Text("${pageNumber+1}"),
                    nextButton
                  ],
                ),
                visible: type != 1,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Advertisement>> fetchAdvertisedAny() async {

    // type = 1 [view right side of user dashboard]
    // type = 2 [view when click My Advertisement]
    // type = 3 [view at the admin panel]
    List<Advertisement> advertisedAnyList = [];

    String url;
    if(type == 1){
      url = baseUrl + "/advertisements/query?type=1&per-page=$perPage&page-index=$pageIndex";
    }else if(type == 2){
      url = baseUrl + "/advertisements/query?type=2&given-by=${userInfo['id']}&per-page=$perPage&page-index=$pageIndex";
    }else {
      url = baseUrl + "/advertisements/query?type=3&per-page=$perPage&page-index=$pageIndex";
    }

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> advertisements = res['advertisements'];
        advertisements.asMap().forEach((key, advertisement) {
          advertisedAnyList.add(new Advertisement(
            id: advertisement['id'],
            title: advertisement['title'],
            targetedDestinationUrl: advertisement['targetedDestinationUrl'],
            bannerImageUrl: advertisement['bannerImageUrl'],
            adCost: advertisement['adCost'],
            adDuration: advertisement['adDuration'],
            givenBy: advertisement['givenBy'],
            createdAt: advertisement['createdAt'],
            status: advertisement['status']
          ));
        });
      }
    }

    setState(() {
      needToFreezeUi = false;
    });

    return advertisedAnyList;

  }

  BoxDecoration headingDecoration() {
    return BoxDecoration(
      border: Border(
        bottom:  BorderSide(
          color: Colors.green,
          width: 1.0,
        )
      ),
    );
  }

  openUrl(String url,BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "Can't open the url!");
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    timer.cancel();
  }

  void onUpdate(BuildContext context, Advertisement advertisement,String status) {

    setState(() {
      needToFreezeUi = true;
    });

    var request = {
      "advertisement": {
        "id" : advertisement.id,
        "status": status,
      }
    };

    String url = baseUrl + '/advertisements';
    Map<String, String> headers = {"Content-type": "application/json"};

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureAdvertisedAny = fetchAdvertisedAny();
          });
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
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


}