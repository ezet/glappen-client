import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garderobel_api/garderobel_api.dart';
import 'package:garderobelappen/receipts.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'scanner.dart';

class TabBarController extends StatefulWidget {
  TabBarController();

  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController> {
  _TabBarControllerState();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    Receipts(),
    Receipts(),
    Receipts(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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

  Center _buildBody() {
    return Center(
      child: _tabs.elementAt(_selectedIndex),
    );
  }

  _showProfileSheet() {
    _buildBottomSheet(Container());
  }

  _buildBottomSheet(Widget child) {
    var radius = Radius.circular(10);
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)),
        builder: (ctx) {
          return Container();
        });
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
                            onTap: () {
                              _showProfileSheet();
                            },
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
    final user = Provider.of<FirebaseUser>(context);
    final GarderobelApi api = Provider.of<GetIt>(context).get<GarderobelApi>();
    final currentReservations = await api.findReservationsForCode(qrCode, user.uid);
    if (currentReservations.isEmpty)
      _handleNewReservation(qrCode);
    else
      await _handleExistingReservations(qrCode);
  }

  _handleNewReservation(String qrCode) async {
    final user = Provider.of<FirebaseUser>(context);
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
