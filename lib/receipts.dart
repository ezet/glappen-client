import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobel_api/models/reservation.dart';
import 'package:garderobelappen/GlappenService.dart';
import 'package:garderobelappen/dashboard.dart';
import 'package:provider/provider.dart';

import 'locator.dart';

class Receipts extends StatelessWidget {
  const Receipts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = locator.get<GarderobelClient>();
    final user = Provider.of<FirebaseUser>(context);
    final reservations = api.findReservationsForUser(user.uid);
    return StreamProvider.value(
        value: reservations, child: ReservationHandler());
  }
}

class NoReceipts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).tr('dashboard.emptyState.title'),
            ),
            Text(
              AppLocalizations.of(context).tr('dashboard.emptyState.body'),
              textAlign: TextAlign.center,
            )
          ],
        )),
      ),
    );
  }
}

class ReservationPaymentAuthRequired extends StatelessWidget {
  final Reservation item;

  const ReservationPaymentAuthRequired({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = locator.get<GlappenService>();

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Awaithing authentication..."),
            RaisedButton(
              child: Text("Try again"),
              onPressed: () {},
            ),
            RaisedButton(
              child: Text("Cancel"),
              onPressed: () async {
                final response = await service.cancelCheckIn(item.docId);
                if (response != null) {
                  Scaffold.of(context).showSnackBar((SnackBar(
                    content:
                        Text("Your reservation was successfully cancelled!"),
                  )));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ReservationPaymentMethodRequired extends StatelessWidget {
  final Reservation item;

  const ReservationPaymentMethodRequired({Key key, this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Please select a different payment method"),
      ),
    );
  }
}

class ReservationHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final list = Provider.of<Iterable<Reservation>>(context)?.toList() ?? [];
    final isAwaitingPayment = list.length > 0 &&
        list[0].state.index < ReservationState.PAYMENT_RESERVED.index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanButtonState>(context).setState(!isAwaitingPayment);
    });

    if (list.length == 0) return NoReceipts();

    final item = list[0];
    if (isAwaitingPayment) {
      if (item.state == ReservationState.PAYMENT_AUTH_REQUIRED) {
        return ReservationPaymentAuthRequired(item: item);
      } else if (item.state == ReservationState.PAYMENT_METHOD_REQUIRED) {
        return ReservationPaymentMethodRequired(item: item);
      } else {
        return Container();
      }
    } else {
      return ReceiptsList();
    }
  }
}

class ReceiptsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final list = Provider.of<Iterable<Reservation>>(context)?.toList() ?? [];
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 0),
        child: Swiper(
          itemBuilder: (context, i) => ReceiptItem(item: list[i]),
          itemCount: list?.length ?? 0,
          loop: false,
          viewportFraction: 0.8,
          scale: 0.93,
//          pagination: SwiperPagination(
//              builder: FractionPaginationBuilder(color: Colors.grey),
//              alignment: Alignment.topCenter),
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class ReceiptItem extends StatelessWidget {
  final Reservation item;

  const ReceiptItem({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = locator.get<GlappenService>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 50, left: 5, right: 5, top: 40),
      child: Card(
        // color: Colors.grey,
        elevation: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      color: HexColor(item.color),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(5))),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            item.venueName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(item.hangerName,
                              style: TextStyle(
                                  fontSize: 60, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                            child: Text(item.wardrobeName ?? "Wardrobe")),
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
                      Text(item.state.toString()),
                      _buildRaisedButton(context, item),
                      RaisedButton(
                        onPressed: () async => buildConfirmationButton(service),
                        child: Text('confirm'),
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

  void buildConfirmationButton(GlappenService service) {
    if (item.state == ReservationState.PAYMENT_RESERVED)
      service.confirmCheckIn(item.docId);
    else if (item.state == ReservationState.CHECKED_IN)
      // service.confirmCheckOut();
      null;
    else
      null;
  }

  RaisedButton _buildRaisedButton(BuildContext context, Reservation item) {
    final service = locator.get<GlappenService>();
    var shape2 =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30));
    if (item.state == ReservationState.PAYMENT_RESERVED) {
      return RaisedButton(
        onPressed: () async {
          final result = await service.cancelCheckIn(item.docId);
          if (result != null) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Your reservation was successfully cancelled, and your payment has been refunded.'),
            ));
          }
        },
        child: Text('CANCEL'),
        shape: shape2,
      );
    } else {
      return RaisedButton(
        onPressed: () async {
          final response = await service.requestCheckOut(item.docId);
        },
        child: Text('CHECK-OUT'),
        shape: shape2,
      );
    }
  }
}
