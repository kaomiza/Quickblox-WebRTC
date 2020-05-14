import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/page/login.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String APP_ID = "79480";
  const String AUTH_KEY = "uwMkDp7D4CJE4Bf";
  const String AUTH_SECRET = "LKkdyCCDRm2rum6";
  const String ACCOUNT_KEY = "ZpfibLk6TBkkkvQEoiBa";
  const String API_ENDPOINT = ""; //optional
  const String CHAT_ENDPOINT = ""; //optional

  try {
    await QB.settings.init(APP_ID, AUTH_KEY, AUTH_SECRET, ACCOUNT_KEY,
        apiEndpoint: API_ENDPOINT, chatEndpoint: CHAT_ENDPOINT);
  } catch (e) {
    print(e.toString());
  }
  try {
    await QB.webrtc.init();
  } catch (e) {
    print(e.toString());
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
      title: 'QB',
    );
  }
}
