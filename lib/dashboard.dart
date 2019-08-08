import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobelappen/3ds_auth.dart';
import 'package:garderobelappen/receipts.dart';
import 'package:garderobelappen/ui/payment_settings.dart';
import 'package:provider/provider.dart';

import 'GlappenService.dart';
import 'locator.dart';
import 'scanner.dart';

class Dashboard extends StatefulWidget {
  Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  _DashboardState();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      key: this.scaffoldKey,
//      appBar: _buildAppBar(),
      body: Receipts(),
//      bottomNavigationBar: _buildBottomNavigationBar(),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
//        label: Text("Check-in"),
//        icon: Icon(Icons.add),
        child: Icon(
          Icons.add,
          size: 40,
        ),
        elevation: 5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        onPressed: () async {
//          Navigator.push(context, MaterialPageRoute(builder: (context) => Checkout()));
          final result = await Navigator.push<String>(
              context, MaterialPageRoute(builder: (context) => Scanner()));
          _handleScanResult(result);
        },
      ),
    );
  }

  _showSettingsSheet() {
    _buildBottomSheet(Container(
      height: 400,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                        radius: 16,
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[Text(user.displayName), Text(user.email)],
                  )
                ],
              ),
              Divider(),
              Container(
                  height: 275,
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Text("Payment"),
                        subtitle: Text("Payment options and related settings"),
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) => PaymentSettings())),
                        leading: Icon(Icons.payment),
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Open-source licenses"),
                      ),
                      ListTile(
                        title: Text("Privay Policy"),
                      ),
//                      ListTile(
//                        title: Text("Terms of Service"),
//                      ),
                      ListTile(
                        title: Text("Sign out"),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ))
            ],
          )),
    ));
  }

  _buildBottomSheet(Widget child) {
    var radius = Radius.circular(10);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)),
        builder: (ctx) => child);
  }

  _showFilterSheet() {
    _buildBottomSheet(Container(
      height: 400,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Filter"),
              RadioListTile(
                title: Text("Active only"),
                value: 1,
                groupValue: 1,
                onChanged: (int) => {},
              ),
              RadioListTile(
                title: Text("All"),
                value: 2,
                groupValue: 1,
                onChanged: (int) => {},
              ),
              Divider(),
              Text("Sort by"),
              RadioListTile(
                title: Text("Date"),
                value: 1,
                groupValue: 1,
                onChanged: (int) => {},
              ),
              RadioListTile(
                title: Text("Venue"),
                value: 2,
                groupValue: 1,
                onChanged: (int) => {},
              ),
            ],
          )),
    ));
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
        shape: AutomaticNotchedShape(RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    height: 48,
                    width: 48,
                    child: Material(
                        child: InkWell(
                            onTap: () => _showSettingsSheet(),
                            child: Icon(Icons.menu, color: Colors.black87)))),
                SizedBox(
                    height: 48,
                    width: 48,
                    child: Material(
                        child: InkWell(
                            onTap: () {
                              _showFilterSheet();
                            },
                            child: Icon(Icons.more_vert, color: Colors.black87))))
              ]),
        ));
  }

  _handleScanResult(String qrCode) async {
    final api = locator.get<GarderobelClient>();
    final currentReservations = await api.findReservationsForCode(qrCode, user.uid);
    if (currentReservations.isEmpty)
      _handleNewReservation(qrCode);
    else
      await _handleExistingReservations(qrCode);
  }

  _handleNewReservation(String qrCode) async {
    final api = locator.get<GlappenService>();
    final reservation = await api.createPaymentIntent('card_1F3o2DKL33qOII4gEqNgzHxG');
    Navigator.push(context, MaterialPageRoute(builder: (context) => ScaAuth(reservation)));

//    final reservation = await api.requestCheckIn(qrCode, user.uid);

    if (reservation == null)
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No free hangers"),
      ));
    else {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Reservation successful")));
    }
  }

  Future<DocumentReference> _handleExistingReservations(String qrCode) {}
}
