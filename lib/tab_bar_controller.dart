import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabBarController extends StatefulWidget {
  TabBarController();

  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController> {
  _TabBarControllerState();

  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
//    Queue(),
//    History(),
//    Employees(),
//    Settings()
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Center _buildBody() {
    return Center(
      child: _tabs.elementAt(_selectedIndex),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
//      showUnselectedLabels: false,

//      unselectedItemColor: Theme.of(context).buttonColor,
      selectedItemColor: Theme.of(context).buttonColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).primaryColor,
          icon: Icon(Icons.people),
//          activeIcon: Icon(
//            Icons.home,
//          ),
          title: Text(
            'Queue',
          ),
        ),
        BottomNavigationBarItem(
          backgroundColor: Theme.of(context).primaryColor,
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
          backgroundColor: Theme.of(context).primaryColor,
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
//    final Venue venue = Provider.of(context);
//    final Section section = Provider.of(context);
//    final GladminApi api = Provider.of<GetIt>(context).get();
    final user = Provider.of<FirebaseUser>(context);

    return AppBar(
//      backgroundColor: Color.fromRGBO(34, 38, 43, 1),
      elevation: 0,
      title: Text(
        "Garderobelappen",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
      actions: <Widget>[
        FlatButton(
          splashColor: Colors.red,
          child: Row(
            children: <Widget>[Text('Scan in')],
          ),
          onPressed: () async => {},
        ),
        FlatButton(
          splashColor: Colors.red,
          child: Row(
            children: <Widget>[Text('Scan out')],
          ),
          onPressed: () async => {},
        ),
      ],
    );
  }
}
