import 'package:flutter/material.dart';
import 'package:garderobelappen/ui/add_payment_method.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_api/stripe.dart';

import '../locator.dart';

class PaymentSettings extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = locator.get<CustomerSession>();
    final future = session.listPaymentMethods();

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment settings"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddPaymentMethod()));
            },
          )
        ],
      ),
      body: MultiProvider(
        providers: [
          FutureProvider<Map<String, dynamic>>.value(
            value: future,
            initialData: {},
            catchError: (context, error) {
              return {};
            },
          ),
          FutureProvider<DefaultPaymentMethod>(
            builder: (context) {
              return SharedPreferences.getInstance().then((prefs) =>
                  DefaultPaymentMethod(
                      prefs.getString('defaultPaymentMethod')));
            },
          )
        ],
        child: PaymentMethodsList(),
      ),
    );
  }
}

class DefaultPaymentMethod {
  final String paymentMethodId;
  DefaultPaymentMethod(this.paymentMethodId);
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stripeSession = locator.get<CustomerSession>();
    final response = Provider.of<Map<String, dynamic>>(context);
    final List listData = response['data'] ?? [];
    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    return ListView.builder(
        itemCount: listData.length,
        itemBuilder: (BuildContext context, int index) {
          final data = listData[index];
          final card = data['card'];
          return ListTile(
            onLongPress: () async {
              final result =
                  await stripeSession.detachPaymentMethod(data['id']);
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Payment method successfully deleted.'),
              ));
            },
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final isSet = await prefs.setString('payment_method', data['id']);
              if (!isSet) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "There was an error setting the default payment method. Please try again"),
                ));
              }
            },
            subtitle: Text(card['last4']),
            title: Text(card['brand']),
            leading: Icon(Icons.credit_card),
            trailing: data['id'] == defaultPaymentMethod.paymentMethodId
                ? Icon(Icons.check_circle)
                : null,
          );
        });
  }
}
