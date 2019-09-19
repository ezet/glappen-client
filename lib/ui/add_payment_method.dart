import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import '../GlappenService.dart';
import '../locator.dart';
import 'utils/masked_text_controller.dart';

class AddPaymentMethod extends StatefulWidget {
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final _expiryDateController = MaskedTextController(mask: '00/00');
  final _cvvCodeController = MaskedTextController(mask: '0000');
  final StripeCard _cardData = StripeCard();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final stripe = locator.get<Stripe>();
    final stripeSession = locator.get<CustomerSession>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Add payment method'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                _formKey.currentState.save();
                if (_formKey.currentState.validate()) {
                  final cardMap = _cardData.toMap();
                  cardMap.remove('object');
                  final cardData = {'type': 'card', 'card': cardMap};
                  final t = await stripe.createPaymentMethod(cardData);
                  await stripeSession.attachPaymentMethod(t['id']);
                  debugPrint(t.toString());
                  // final token = await stripe.createCardToken(_cardData);
                  // final setupIntent =
                  // await glappen.createPaymentMethod(token.id);
                  // await stripeSession.attachPaymentMethod(result.id);
                  // debugPrint(token.toString());
                }
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: _cardNumberController,
                    autovalidate: true,
                    onSaved: (text) => _cardData.number = text,
                    validator: (text) {
                      return isValidLuhnNumber(text) ? null : "Invalid number";
                    },
                    decoration: InputDecoration(
                      prefixIcon: getCardTypeIcon(_cardNumberController.text),
                      border: OutlineInputBorder(),
                      labelText: 'Card number',
                      hintText: 'xxxx xxxx xxxx xxxx',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    validator: (text) {
                      return null;
                    },
                    onSaved: (text) {
                      final arr = text.split("/");
                      _cardData.expMonth = int.tryParse(arr[0]);
                      _cardData.expYear = int.tryParse(arr[1]);
                    },
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expired Date',
                        hintText: 'MM/YY'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 8),
                  child: TextFormField(
//                  focusNode: cvvFocusNode,
                    validator: (text) =>
                        _cardData.validateCVC() ? null : "Invalid CVC",
                    onSaved: (text) => _cardData.cvc = text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CVV',
                      hintText: 'XXXX',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,

//                    onChanged: (String text) {
//                    setState(() {
//                      cvvCode = text;
//                    });
//                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    onSaved: (text) => _cardData.name = text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Card Holder',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
