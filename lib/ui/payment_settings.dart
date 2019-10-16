import 'package:flutter/material.dart';
import 'package:garderobelappen/ui/add_payment_method.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import '../locator.dart';
import 'confirm_purchase_screen.dart';

class PaymentSettings extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final paymentMethods = Provider.of<PaymentMethods>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Payment settings"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final added =
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPaymentMethod()));
                if (added) await paymentMethods.refresh();
              },
            )
          ],
        ),
        body: ChangeNotifierProvider(builder: (_) => DefaultPaymentMethod(), child: PaymentMethodsList()));
  }
}

class PaymentMethods extends ChangeNotifier {
  List<PaymentMethod> paymentMethods = List();
  Future<List<PaymentMethod>> paymentMethodsFuture;

  PaymentMethods() {
    refresh();
  }

  Future<void> refresh() {
    final session = locator.get<CustomerSession>();
    return session.listPaymentMethods().then((value) {
      final List listData = value['data'] ?? List<PaymentMethod>();
      if (listData.length == 0) {
        paymentMethods = List();
      } else {
        paymentMethods =
            listData.map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'])).toList();
      }
      notifyListeners();
    });
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
    final paymentMethods = Provider.of<PaymentMethods>(context);
    final listData = paymentMethods.paymentMethods;
    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    if (listData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => paymentMethods.refresh(),
      child: buildListView(listData, stripeSession, defaultPaymentMethod, paymentMethods),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, CustomerSession stripeSession,
      DefaultPaymentMethod defaultPaymentMethod, PaymentMethods paymentMethods) {
    if (listData.length == 0) {
      return ListView();
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return ListTile(
              onLongPress: () async {
                final result = await stripeSession.detachPaymentMethod(card.id);
                await paymentMethods.refresh();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Payment method successfully deleted.'),
                ));
              },
              onTap: () => defaultPaymentMethod.set(card.id),
              subtitle: Text(card.last4),
              title: Text(card.brand),
              leading: Icon(Icons.credit_card),
              trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
            );
          });
    }
  }
}
