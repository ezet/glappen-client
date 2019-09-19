import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:garderobelappen/ui/payment_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import '../locator.dart';

class ConfirmPurchaseResult {
  final String paymentMethod;
  final int numTickets;

  const ConfirmPurchaseResult(this.paymentMethod, this.numTickets);
}

class ConfirmPurchase extends StatefulWidget {
  @override
  _ConfirmPurchaseState createState() => _ConfirmPurchaseState();
}

class _ConfirmPurchaseState extends State<ConfirmPurchase> {
  int count = 1;
  String paymentMethod;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((it) {
      setState(() {
        paymentMethod = it.getString(DefaultPaymentMethod.defaultPaymentMethod);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              loc.tr('confirmPurchase.title'),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Spacer(
              flex: 3,
            ),
            Row(
              children: <Widget>[
                Text("Kjøp "),
                NumberPicker(
                  value: count,
                  onChanged: (int value) => setState(() {
                    count = value;
                  }),
                ),
                Text("garderobeplass"),
              ],
            ),
            Spacer(
              flex: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Betalingsmetode"),
            ),
            PaymentMethodSelector(
              selectedPaymentMethod: this.paymentMethod,
              onChanged: (method) => this.setState(() {
                this.paymentMethod = method;
              }),
            ),
            Spacer(
              flex: 3,
            ),
            Text(loc.tr('confirmPurchase.body')),
            Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text("Avbryt"),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                RaisedButton(
                  child: Text("Neste"),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(ConfirmPurchaseResult(paymentMethod, count));
                  },
                )
              ],
            ),
            Spacer(
              flex: 1,
            )
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod(this.id, this.last4, this.brand);
}

class PaymentMethodSelector extends StatefulWidget {
  PaymentMethodSelector(
      {Key key, @required this.selectedPaymentMethod, @required this.onChanged})
      : super(key: key);

  final String selectedPaymentMethod;
  final void Function(String) onChanged;

  @override
  _PaymentMethodSelectorState createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  Future<List<PaymentMethod>> paymentMethodsFuture;

  @override
  void initState() {
    super.initState();
    final session = locator.get<CustomerSession>();
    paymentMethodsFuture = session.listPaymentMethods().then((value) {
      final List listData =
          value['data'] ?? Future.value(List<PaymentMethod>());
      if (listData.length == 0) {
        return Future.value(List<PaymentMethod>());
      }
      final list = listData
          .map((item) => PaymentMethod(
              item['id'], item['card']['last4'], item['card']['brand']))
          .toList();
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: paymentMethodsFuture,
      initialData: [PaymentMethod(null, "loading", "NOBRAND")],
      builder: (context, AsyncSnapshot<List<PaymentMethod>> snapshot) {
        final paymentMethods = snapshot.data;
        final method = paymentMethods?.singleWhere(
            (item) => item.id == widget.selectedPaymentMethod,
            orElse: () => null);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: DropdownButton(
            underline: null,
            isExpanded: true,
            value: method?.id,
            items: paymentMethods
                ?.map((item) => DropdownMenuItem(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("**** **** **** ${item.last4}"),
                      ),
                      value: item.id,
                    ))
                ?.toList(),
            onChanged: (value) => widget.onChanged(value),
          ),
        );
      },
    );
  }
}

class NumberPicker extends StatelessWidget {
  const NumberPicker({
    Key key,
    @required this.value,
    @required this.onChanged,
  }) : super(key: key);

  final void Function(int value) onChanged;
  final int value;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              if (value > 1) onChanged(value - 1);
            },
          ),
          Text(value.toString()),
          IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: () {
              if (value < 10) onChanged(value + 1);
            },
          ),
        ],
      );
}
