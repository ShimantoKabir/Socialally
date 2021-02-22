import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/constants.dart';
import 'package:client/models/Advertisement.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:responsive_image/responsive_image.dart';
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
  int perPage = 5;
  int pageNumber = 0;

  @override
  void initState() {
    super.initState();
    if(type == 2){
      eventHub.fire("viewTitle","Advertised Any");
    }

    futureAdvertisedAny = fetchAdvertisedAny();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: futureAdvertisedAny,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Advertisement> advertisements = snapshot.data;
              if(advertisements.length == 0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text("No advertisement found!"),
                  ),
                );
              }else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: advertisements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10,5,10,5),
                            child: Text(
                              advertisements[index].title,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                              ),
                            ),
                            decoration: headingDecoration(),
                          ),
                          SizedBox(height: 5),
                          ResponsiveImage(
                            srcSet: {
                              1024: advertisements[index].bannerImageUrl,
                            },
                            builder: (BuildContext context, String url) {
                              return CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) => Center(
                                  child: Padding(
                                    child: CircularProgressIndicator(),
                                    padding: EdgeInsets.all(20),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              child: Text(
                                advertisements[index].targetedDestinationUrl,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: (){
                                openUrl(advertisements[index].targetedDestinationUrl, context);
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  },
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
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 15
                    ),
                    onPressed: (){
                      if(pageIndex < 1){
                        Alert.show(alertDialog, context, Alert.ERROR, "Your are already in the first page!");
                      }else {
                        pageNumber--;
                        pageIndex = pageIndex - perPage;
                        needToFreezeUi = true;
                        setState(() {
                          futureAdvertisedAny = fetchAdvertisedAny();
                        });
                      }
                    }
                  ),
                  Text("${pageNumber+1}"),
                  IconButton(
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
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Advertisement>> fetchAdvertisedAny() async {

    List<Advertisement> advertisedAnyList = [];

    String url;
    if(type == 2){
      url = baseUrl + "/advertisements/query?given-by=${userInfo['id']}&per-page=$perPage&page-index=$pageIndex";
    }else {
      url = baseUrl + "/advertisements/query?per-page=$perPage&page-index=$pageIndex";
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
            createdAt: advertisement['createdAt']
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

}