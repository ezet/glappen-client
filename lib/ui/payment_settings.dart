import 'package:flutter/material.dart';
import 'package:garderobelappen/main.dart';
import 'package:garderobelappen/ui/add_payment_method.dart';
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddPaymentMethod()));
            },
          )
        ],
      ),
      body: FutureProvider<Map<String, dynamic>>.value(
        value: future,
        initialData: {},
        child: PaymentMethodsList(),
        catchError: (context, error) {
          return {};
        },
      ),
    );
  }
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stripeApi = StripeApiHandler();
    final stripeData = Provider.of<StripeData>(context);
    final response = Provider.of<Map<String, dynamic>>(context);
    final List listData = response['data'] ?? [];
    return ListView.builder(
        itemCount: listData.length,
        itemBuilder: (BuildContext context, int index) {
          final data = listData[index];
          final card = data['card'];
          return ListTile(
            onLongPress: () async {
              final result = await stripeApi.detachPaymentMethod(
                  stripeData.customerId, data['id'], stripeData.secretKey);
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Payment method successfully deleted.'),
              ));
            },
            onTap: () async {},
            subtitle: Text(card['last4']),
            title: Text(card['brand']),
            leading: Icon(Icons.credit_card),
          );
        });
  }
}
