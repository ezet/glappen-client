import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobel_api/models/reservation.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class Receipts extends StatelessWidget {
  const Receipts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<GetIt>(context).get<GarderobelClient>();
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
    api = Provider.of<GetIt>(context).get();
    user = Provider.of<FirebaseUser>(context);
    // TODO: implement build
    final list = Provider.of<Iterable<Reservation>>(context)?.toList() ?? [];
    return ListView.builder(
      itemBuilder: (context, i) => _buildListItem(context, list[i]),
      itemCount: list?.length ?? 0,
    );
  }

  Widget _buildListItem(BuildContext context, Reservation item) {
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
