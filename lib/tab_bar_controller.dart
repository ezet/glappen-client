import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garderobel_api/garderobel_api.dart';
import 'package:garderobelappen/bottom_bar.dart';
import 'package:garderobelappen/dashboard.dart';
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
    Dashboard(),
    Dashboard(),
    Dashboard(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this.scaffoldKey,
//      appBar: _buildAppBar(),
      body: Dashboard(),
//      bottomNavigationBar: _buildBottomNavigationBar(),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Check-in"),
//        icon: Icon(Icons.add),
        elevation: 5,
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

  Widget _buildBottomAppBar() {
    return FABBottomAppBar(
      notchedShape:
          AutomaticNotchedShape(RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
      items: [
        FABBottomAppBarItem(iconData: Icons.event_note, text: "Tickets"),
        FABBottomAppBarItem(iconData: Icons.person, text: "Profile")
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
//      showUnselectedLabels: false,

//      unselectedItemColor: Theme.of(context).buttonColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
//          activeIcon: Icon(
//            Icons.home,
//          ),
          title: Text(
            'Queue',
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          title: Text(
            'History',
          ),
        ),
//        BottomNavigationBarItem(
//          backgroundColor: Theme.of(context).primaryColor,
//          icon: Icon(Icons.person),
//          title: Text(
//            "Profile",
//          ),
//        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
//            color: Colors.amber,
          ),
          title: Text('Settings'),
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
//      backgroundColor: Color.fromRGBO(34, 38, 43, 1),
      elevation: 0,
      title: Text(
        "Garderobelappen",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
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
