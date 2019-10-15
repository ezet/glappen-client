import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garderobelappen/receipts.dart';
import 'package:garderobelappen/ui/confirm_purchase_screen.dart';
import 'package:garderobelappen/ui/payment_settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'GlappenService.dart';
import 'locator.dart';
import 'scanner.dart';

class ScanButtonState extends ChangeNotifier {
  bool enabled = true;

  setState(bool state) {
    final notify = enabled != state;
    enabled = state;
    if (notify) notifyListeners();
  }
}

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
    final fabState = Provider.of<ScanButtonState>(context);

    return Scaffold(
      key: this.scaffoldKey,
//      appBar: _buildAppBar(),
      body: Receipts(),
//      bottomNavigationBar: _buildBottomNavigationBar(),
      bottomNavigationBar: _buildBottomAppBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
//        label: Text("Check-in"),
//        icon: Icon(Icons.add),
          child: Icon(
            Icons.add,
            size: 24,
          ),
          elevation: 5,
          backgroundColor: fabState.enabled ? Colors.pink : Colors.grey,
          foregroundColor: Colors.white,
          onPressed: fabState.enabled ? () => _tryScan() : null),
    );
  }

  _tryScan() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentMethodId = prefs.getString(DefaultPaymentMethod.defaultPaymentMethod);
    if (paymentMethodId == null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please set a payment method first."),
      ));
      return;
    }
    final result =
        await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => Scanner()));
    await _handleNewReservation(result);
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

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
        // shape: AutomaticNotchedShape(RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
        elevation: 0,
        color: Theme.of(context).canvasColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
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
                            child: Icon(Icons.search, color: Colors.black87))))
              ]),
        ));
  }

  Future<ConfirmPurchaseResult> _showPurchaseOptionScreen(String qrCode) {
    return Navigator.of(context).push<ConfirmPurchaseResult>(
        MaterialPageRoute(builder: (BuildContext context) => ConfirmPurchase()));
  }

  _handleNewReservation(String qrCode) async {
    final api = locator.get<GlappenService>();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()));

    Navigator.of(context).pop();

    // if (reservationData == null) {
    // scaffoldKey.currentState.showSnackBar(SnackBar(
    // content: Text("No free hangers"),
    // ));
    // return;
    // }

    final result = await _showPurchaseOptionScreen(qrCode);
    if (result == null) {
      return;
    } else {
      final reservationData = await api.requestCheckIn(
          qrCode, result.paymentMethod, result.numTickets, Stripe.getReturnUrl());
      await _handlePaymentIntent(reservationData, reservationData['id']);
    }
  }

  _handlePaymentIntent(Map paymentIntent, String reservationId) async {
    final api = locator.get<GlappenService>();
    final stripe = locator.get<Stripe>();
    if (paymentIntent == null) {
      scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("There was an error processing your payment. Please try again.")));
    } else if (paymentIntent['status'] == 'requires_action') {
      // todo: show waiting screen
      // final intent = await launch3ds(paymentIntent['next_action']);

      final intent = await stripe.authenticatePayment(paymentIntent['client_secret']);

      _handlePaymentIntent(intent, reservationId);
    } else if (paymentIntent['status'] == 'requires_confirmation') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()));
      final confirmation = await api.confirmPayment(reservationId);
      Navigator.of(context).pop();
      await _handlePaymentIntent(confirmation, reservationId);
    } else if (paymentIntent['status'] == 'requires_payment_method') {
      // todo
    } else if (paymentIntent['status'] == 'requires_capture') {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Reservation successful")));
    } else {
      scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("There was an error processing your payment. Please try again.")));
    }
  }
}
