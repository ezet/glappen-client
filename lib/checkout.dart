import 'package:flutter/material.dart';
import 'package:stripe_api/src/stripe_api.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Container(
          alignment: Alignment.topCenter,
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 12.0),
              new TextField(
                controller: controller,
                inputFormatters: [
                  CardNumberFormatter(onCardBrandChanged: (brand) {
                    print('onCardBrandChanged : ' + brand);
                  }, onCardNumberComplete: () {
                    print('onCardNumberComplete');
                  }, onShowError: (isError) {
                    print('Is card number valid ? ${!isError}');
                  }),
                ],
              ),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _startSession, child: new Text('Start Session')),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _getCustomer, child: new Text('Get Customer')),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _endSession, child: new Text('End Session')),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _saveCard, child: new Text('Save Card')),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _changeDefaultCard, child: new Text('Change Default')),
              new SizedBox(height: 12.0),
              new FlatButton(onPressed: _deleteCard, child: new Text('Delete Card')),
              new SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  void _startSession() {
//    CustomerSession.initCustomerSession(_createEphemeralKey);
  }

  void _getCustomer() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      print(customer);
    } catch (error) {
      print(error);
    }
  }

  void _endSession() {
    CustomerSession.endCustomerSession();
  }

  void _saveCard() {
    StripeCard card =
        new StripeCard(number: '4242 4242 4242 4242', cvc: '713', expMonth: 5, expYear: 2019);
    card.name = 'Jhonny Bravo';
    Stripe.instance.createCardToken(card).then((c) {
      print(c);
      return CustomerSession.instance.addCustomerSource(c.id);
    }).then((source) {
      print(source);
    }).catchError((error) {
      print(error);
    });
  }

  void _changeDefaultCard() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      final card = customer.sources[1].asCard();
      final v = await CustomerSession.instance.updateCustomerDefaultSource(card.id);
      print(v);
    } catch (error) {
      print(error);
    }
  }

  void _deleteCard() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      String id;
      for (var c in customer.sources) {
        StripeCard card = c.asCard();
        if (card != null) {
          id = card.id;
          break;
        }
      }

      final v = await CustomerSession.instance.deleteCustomerSource(id);
      print(v);
    } catch (error) {
      print(error);
    }
  }
}

class CardItem extends StatelessWidget {
  final StripeCard card;

  const CardItem({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
