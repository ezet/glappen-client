import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import '../GlappenService.dart';
import '../locator.dart';

class AddPaymentMethod extends StatefulWidget {
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final StripeCard _cardData = StripeCard();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<Map<String, dynamic>> setupIntent;

  @override
  Widget build(BuildContext context) {
    final stripeApi = locator.get<StripeApi>();
    final stripe = locator.get<Stripe>();
    final stripeSession = locator.get<CustomerSession>();
    final glappenService = locator.get<GlappenService>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Add payment method'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  final cardMap = _cardData.toMap();
                  cardMap.remove('object');
                  final cardData = {'type': 'card', 'card': cardMap};
                  var paymentMethod =
                      await stripeApi.createPaymentMethod(cardData);
                  paymentMethod = await stripeSession
                      .attachPaymentMethod(paymentMethod['id']);
                  final createSetupIntentResposne = await glappenService
                      .createSetupIntent(paymentMethod['id']);
                  var setupIntent = await stripe.confirmSetupIntent(
                      createSetupIntentResposne['client_secret']);
                }
              },
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardForm(
              _validationModel: _cardData,
              formKey: _formKey,
            )));
  }
}
