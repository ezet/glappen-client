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
                  var paymentMethod = await stripeApi.createPaymentMethodFromCard(_cardData);
                  paymentMethod = await stripeSession.attachPaymentMethod(paymentMethod['id']);
                  final createSetupIntentResponse = await glappenService.createSetupIntent(paymentMethod['id']);

                  if (createSetupIntentResponse['status'] == 'succeeded') {
                    Navigator.pop(context, true);
                    return;
                  }
                  var setupIntent = await stripe.confirmSetupIntent(createSetupIntentResponse['client_secret']);

                  if (setupIntent['status'] == 'succeeded') {
                    Navigator.pop(context, true);
                    return;
                  }
                }
              },
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardForm(
              card: _cardData,
              formKey: _formKey,
            )));
  }
}
