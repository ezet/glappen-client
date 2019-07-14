import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garderobel_api/garderobel_api.dart';
import 'package:garderobelappen/receipts.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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
                        leading: Icon(Icons.payment),
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Open-source licenses"),
                      ),
                      ListTile(
                        title: Text("Privay Policy"),
                      ),
                      ListTile(
                        title: Text("Terms of Service"),
                      ),
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
    _buildBottomSheet(Container());
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
    final GarderobelApi api = Provider.of<GetIt>(context).get<GarderobelApi>();
    final currentReservations = await api.findReservationsForCode(qrCode, user.uid);
    if (currentReservations.isEmpty)
      _handleNewReservation(qrCode);
    else
      await _handleExistingReservations(qrCode);
  }

  _handleNewReservation(String qrCode) async {
    final GarderobelApi api = Provider.of<GetIt>(context).get<GarderobelApi>();
    final reservation = await api.createReservation(qrCode, user.uid);
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
