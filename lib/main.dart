import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:garderobelappen/sign_in.dart';
import 'package:provider/provider.dart';

import 'GlappenService.dart';
import 'dashboard.dart';
import 'locator.dart';

void main() {
  getLocator();
  runApp(
    Garderobelappen(),
  );
}

class StripeData {
  final customerId;

  StripeData(this.customerId);
}

class Garderobelappen extends StatelessWidget {
  static const String _title = 'Garderobelappen';

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    var materialApp = MaterialApp(
      title: _title,
      theme: ThemeData(
          // accentColor: Colors.lightBlueAccent,
          primarySwatch: Colors.orange),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        //app-specific localization
        EasylocaLizationDelegate(locale: data.locale, path: 'assets/l8n'),
      ],
      supportedLocales: [Locale('en', 'US'), Locale('no', 'NO')],
      locale: data.savedLocale,
      home: Authenticator(),
//      initialRoute: Authenticator.routeName,
    );

    final localizationProvider =
        EasyLocalizationProvider(data: data, child: materialApp);

    return MultiProvider(providers: [
      StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged),
      StreamProvider<StripeData>.value(
        value: locator.get<GlappenService>().getCurrentUserStripeId(),
      ),
    ], child: localizationProvider);
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
//      final api = locator.get<GladminApi>();
//      final user = User(
//          docId: _currentUser.uid,
//          name: _currentUser.displayName,
//          email: _currentUser.email,
//          phone: _currentUser.phoneNumber,
//          photoUrl: _currentUser.photoUrl);
//      api.updateUser(user);

      return ChangeNotifierProvider.value(
          value: ScanButtonState(), child: Dashboard());
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
