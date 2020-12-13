import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';

import 'home.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _username;

  void _loginToQuickBlox(String login, String password) async {
    QBUser qbUser;
    QBSession qbSession;
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
    try {
      QBLoginResult result = await QB.auth.login(login, password);
      qbUser = result.qbUser;
      qbSession = result.qbSession;
      print(qbSession.tokenExpirationDate);
      print(qbUser.fullName);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    qbSession: qbSession,
                    qbUser: qbUser,
                  )));
    } catch (e) {
      print(e.toString());
    }
    try {
      await QB.chat.connect(qbUser.id, 'quickblox');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RTC'),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                )
              ],
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onSaved: (value) => _username = value, // <= NEW
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => _password = value, // <= NEW
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        final form = _formKey.currentState;
                        form.save();
                        if (_formKey.currentState.validate()) {
                          _loginToQuickBlox(_username, _password);
                          print(_password);
                          print(_username);
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
