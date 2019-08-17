import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobel_api/models/reservation.dart';
import 'package:provider/provider.dart';

import 'locator.dart';

class Receipts extends StatelessWidget {
  const Receipts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = locator.get<GarderobelClient>();
    final user = Provider.of<FirebaseUser>(context);
    final reservations = api.findReservationsForUser(user.uid);
    return StreamProvider.value(value: reservations, child: ReceiptsList());
  }
}

class ReceiptsList extends StatelessWidget {
  GarderobelClient api;
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    api = locator.get();
    user = Provider.of<FirebaseUser>(context);
    // TODO: implement build
    final list = Provider.of<Iterable<Reservation>>(context)?.toList() ?? [];
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 100, horizontal: 0),
        child: Swiper(
          itemBuilder: (context, i) => _buildListItem(context, list[i]),
          itemCount: list?.length ?? 0,
          loop: false,
          // controller: SwiperController(),
        ),
      ),
    );

    // return ListView.builder(
    //   itemBuilder: (context, i) => _buildListItem(context, list[i]),
    //   itemCount: list?.length ?? 0,
    // );
  }

  Widget _buildListItem(BuildContext context, Reservation item) {
    return Card(
      // color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
              child: Container(
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5))),
            child: Text(
              "Test",
              style: TextStyle(fontSize: 20),
            ),
          )),
          Expanded(child: Container(),
          flex: 3,)
        ],
      ),
    );
  }

  Widget _buildListItem2(BuildContext context, Reservation item) {
    return Card(
      child: ListTile(
        onTap: () async {
          await api.requestCheckOut(item.ref);
        },
        title: Text(item?.venueName ?? ''),
        leading: Icon(Icons.event_note),
        subtitle: Text(item.state.toString()),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
