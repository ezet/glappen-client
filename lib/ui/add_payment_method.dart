import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_api/stripe.dart';

import '../main.dart';
import 'utils/masked_text_controller.dart';

class AddPaymentMethod extends StatefulWidget {
  @override
  _AddPaymentMethodState createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
  final _expiryDateController = MaskedTextController(mask: '00/00');
  final _cvvCodeController = MaskedTextController(mask: '0000');
  final StripeCard _cardData = StripeCard();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final stripeApi = StripeApiHandler();
    final stripeData = Provider.of<StripeData>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Add payment method'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                _formKey.currentState.save();
                if (_formKey.currentState.validate()) {
                  final result = await stripeApi.createPaymentMethod(
                      stripeData.customerId, _cardData, stripeData.secretKey);
                  debugPrint(result.toString());
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
                      return "";
                    },
                    onSaved: (text) {
                      final arr = text.split("/");
                      _cardData.expMonth = int.tryParse(arr[0]);
                      _cardData.expYear = int.tryParse(arr[1]);
                    },
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Expired Date', hintText: 'MM/YY'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 8),
                  child: TextFormField(
//                  focusNode: cvvFocusNode,
                    validator: (text) => _cardData.validateCVC() ? null : "Invalid CVC",
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
