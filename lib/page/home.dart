import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/mappers/qb_rtc_session_mapper.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key, this.qbUser, this.qbSession}) : super(key: key);

  final QBUser qbUser;
  final QBSession qbSession;

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  void initState() {
    super.initState();
  }

  RTCVideoViewController _localVideoViewController;
  RTCVideoViewController _remoteVideoViewController;

  void _onLocalVideoViewCreated(RTCVideoViewController controller) {
    _localVideoViewController = controller;
  }

  void _onRemoteVideoViewCreated(RTCVideoViewController controller) {
    _remoteVideoViewController = controller;
  }

  static const CHANNEL_NAME = "FlutterQBUsersChannel";
  static const _usersModule = const MethodChannel(CHANNEL_NAME);

  Future<CustomQBUser> getUsers() async {
    Map<String, Object> data = new Map();

    Map<dynamic, dynamic> list =
        await _usersModule.invokeMethod("getUsers", data);

    var jsonData = json.decode(json.encode(list));

    CustomQBUser userData = CustomQBUser.fromJson(jsonData);
    print(userData);
    return userData;
  }

  Future<List<Users>> _getAllUserById() async {
    List<Users> userList;
    try {
      CustomQBUser data = await getUsers();
      userList = data.users;
      return userList;
    } on PlatformException catch (e) {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('ListUser'),
      ),
      body: Container(
        margin: MediaQuery.of(context).padding,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(widget.qbUser.fullName),
                FutureBuilder<List<Users>>(
                  future: _getAllUserById(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(snapshot.data[index].fullName),
                          );
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                Container(
                    child: new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  width: 160.0,
                  height: 160.0,
                  child: RTCVideoView(
                    onVideoViewCreated: _onLocalVideoViewCreated,
                  ),
                  decoration: new BoxDecoration(color: Colors.black54),
                )),
                Container(
                  child: new Container(
                    margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: 160.0,
                    height: 160.0,
                    child: RTCVideoView(
                      onVideoViewCreated: _onRemoteVideoViewCreated,
                    ),
                    decoration: new BoxDecoration(color: Colors.black54),
                  ),
                ),
                Container(
                  child: RaisedButton(
                    onPressed: () async {
                      QBSession sessionG;
                      try {
                        QBSession session = await QB.auth.getSession();
                        sessionG = session;

                      } on PlatformException catch (e) {
                        // Some error occured, look at the exception message for more details
                      }
                      var respone = await http.get("https://api.quickblox.com/session.json", headers: {
                        "QB-Token":sessionG.token
                      });
                      print("-----------------------");
                      var res = json.decode(respone.body);
                      var sessionid = res["session"]["id"];
                      var useid = res["session"]["user_id"];
                      print(res);
                      // int opponentId = 3928;

                      Future<void> play() async {
                        _localVideoViewController.play(sessionid, useid);
                        // _remoteVideoViewController.play(sessionId, opponentId);
                      }
                      play();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomQBUser {
  List<Users> users;
  int perPage;
  int total;
  int page;

  CustomQBUser({this.users, this.perPage, this.total, this.page});

  CustomQBUser.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = new List<Users>();
      json['users'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
    perPage = json['perPage'];
    total = json['total'];
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users.map((v) => v.toJson()).toList();
    }
    data['perPage'] = this.perPage;
    data['total'] = this.total;
    data['page'] = this.page;
    return data;
  }
}

class Users {
  int id;
  String login;
  String lastRequestAt;
  String fullName;

  Users({this.id, this.login, this.lastRequestAt, this.fullName});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    login = json['login'];
    lastRequestAt = json['lastRequestAt'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['login'] = this.login;
    data['lastRequestAt'] = this.lastRequestAt;
    data['fullName'] = this.fullName;
    return data;
  }
}
