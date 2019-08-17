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
        margin: EdgeInsets.only(top: 100),
        child: Swiper(
          itemBuilder: (context, i) => _buildListItem(context, list[i]),
          itemCount: list?.length ?? 0,
          loop: false,
          viewportFraction: 0.8,
          scale: 0.93,
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Reservation item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50, left: 5, right: 5),
      child: Card(
        // color: Colors.grey,
        elevation: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(5))),
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Expanded(
                        child: Center(
                          child: Text(item.hangerName,
                              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: Center(child: Text(item.wardrobeName ?? "Wardrobe")),
                        flex: 1,
                      )
                    ],
                  ),
                )),
            Expanded(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {},
                        child: Text('HENT'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      )
                    ],
                  ),
                ),
              ),
              flex: 3,
            )
          ],
        ),
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
