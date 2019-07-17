import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garderobelappen/sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'locator.dart';
import 'dashboard.dart';

void main() {
  runApp(
    Garderobelappen(),
  );
}

class Garderobelappen extends StatelessWidget {
  static const String _title = 'Garderobeladmin';

  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: _title,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Authenticator(),
//      initialRoute: Authenticator.routeName,
    );

    return MultiProvider(providers: [
      StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged),
      Provider<GetIt>.value(value: getLocator(context)),
    ], child: materialApp);
  }
}

class Authenticator extends StatefulWidget {
  static const routeName = '/';

  Authenticator({Key key}) : super(key: key);

  _AuthenticatorState createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;
  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return SignIn();
    } else {
//      final api = Provider.of<GetIt>(context).get<GladminApi>();
//      final user = User(
//          docId: _currentUser.uid,
//          name: _currentUser.displayName,
//          email: _currentUser.email,
//          phone: _currentUser.phoneNumber,
//          photoUrl: _currentUser.photoUrl);
//      api.updateUser(user);

      return Dashboard();
    }
  }

  void _checkCurrentUser() async {
    _currentUser = await _auth.currentUser();
    _currentUser?.getIdToken(refresh: true);
    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
    });
  }
}
