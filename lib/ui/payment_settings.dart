import 'package:flutter/material.dart';
import 'package:garderobelappen/ui/add_payment_method.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe.dart';

import '../locator.dart';

class PaymentSettings extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = locator.get<CustomerSession>();
    final paymentMethodsFuture = session.listPaymentMethods();

    return Scaffold(
        appBar: AppBar(
          title: Text("Payment settings"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => AddPaymentMethod()));
              },
            )
          ],
        ),
        body: MultiProvider(providers: [
          FutureProvider<Map<String, dynamic>>.value(
            value: paymentMethodsFuture,
            initialData: {},
            catchError: (context, error) {
              debugPrint(error.toString());
              return {};
            },
          ),
          ChangeNotifierProvider<DefaultPaymentMethod>.value(value: DefaultPaymentMethod())
        ], child: PaymentMethodsList()));
  }
}

class DefaultPaymentMethod extends ChangeNotifier {
  String paymentMethodId = "";
  DefaultPaymentMethod() {
    init();
  }
  static const String defaultPaymentMethod = 'defaultPaymentMethod';

  init() async {
    final prefs = await SharedPreferences.getInstance();
    paymentMethodId = prefs.getString(defaultPaymentMethod);
    notifyListeners();
  }

  set(String newPaymentMethod) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(defaultPaymentMethod, newPaymentMethod).whenComplete(() => prefs.commit());
    paymentMethodId = newPaymentMethod;
    notifyListeners();
  }
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stripeSession = locator.get<CustomerSession>();
    final response = Provider.of<Map<String, dynamic>>(context);
    final List listData = response['data'] ?? [];
    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    if (listData.length == 0) {
      return Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => Future.value(null),
      child: ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final data = listData[index];
            final card = data['card'];
            return ListTile(
              onLongPress: () async {
                final result = await stripeSession.detachPaymentMethod(data['id']);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Payment method successfully deleted.'),
                ));
              },
              onTap: () => defaultPaymentMethod.set(data['id']),
              subtitle: Text(card['last4']),
              title: Text(card['brand']),
              leading: Icon(Icons.credit_card),
              trailing: data['id'] == defaultPaymentMethod.paymentMethodId
                  ? Icon(Icons.check_circle)
                  : null,
            );
          }),
    );
  }
}
