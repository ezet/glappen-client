import 'package:flutter/material.dart';
import 'package:garderobelappen/main.dart';
import 'package:provider/provider.dart';
import 'package:stripe_api/stripe.dart';

class PaymentSettings extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final stripeApi = StripeApiHandler();
    final stripeData = Provider.of<StripeData>(context);
    final future = stripeApi.listPaymentMethods(stripeData.customerId, stripeData.secretKey);

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment settings"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _buildBottomSheet(context);
            },
          )
        ],
      ),
      body: FutureProvider<Map<String, dynamic>>.value(
        value: future,
        initialData: {},
        child: PaymentMethodsList(),
        catchError: (context, error) {
          debugPrint(error);
          return {};
        },
      ),
    );
  }

  _buildBottomSheet(BuildContext context) {
    var radius = Radius.circular(10);
    var brand = "";
    var valid = true;
    var complete = false;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)),
        builder: (ctx) => Container(
              height: 400,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        autovalidate: true,
                        validator: (String text) =>
                            isValidLuhnNumber(text) ? null : "Invalid number",
                        controller: controller,
                        decoration:
                            InputDecoration(errorText: valid == false ? "Invalid number" : null),
                        inputFormatters: [
                          CardNumberFormatter(onCardBrandChanged: (brand) {
                            print('onCardBrandChanged : ' + brand);
                            brand = brand;
                          }, onCardNumberComplete: () {
                            print('onCardNumberComplete');
                            complete = true;
                          }),
                        ],
                      ),
                      TextField()
                    ],
                  )),
            ));
  }
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final response = Provider.of<Map<String, dynamic>>(context);
    final List listData = response['data'] ?? [];
    debugPrint(response.toString());
    return ListView.builder(
        itemCount: listData.length,
        itemBuilder: (BuildContext context, int index) {
          final data = listData[index];
          final card = data['card'];
          return ListTile(
            onTap: () {},
            subtitle: Text(card['last4']),
            title: Text(card['brand']),
            leading: Icon(Icons.credit_card),
          );
        });
  }
}
