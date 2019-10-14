import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobelappen/main.dart';

class GlappenService {
  GarderobelClient client;
  CloudFunctions cf;

  GlappenService(this.client, this.cf);

  /// Utility function to call a Firebase Function
  Future<T> _call<T>(String name, Map params) async {
    log('GlappenService._call, $name, $params');
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: name,
    );
    try {
      final result = await callable.call(params);
      print(result);
      print(result.data);
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      log(e.toString());
      return null;
    }
  }

  /// Request check-in
  Future<Map> requestCheckIn(
      String qrCode, String paymentMethodId, int count, String returnUrl) async {
    return _call('requestCheckIn', {
      'code': qrCode,
      'tickets': count,
      'payment_method_id': paymentMethodId,
      'return_url': returnUrl
    });
  }

  /// Cancel an on-going check-in.
  Future<List<dynamic>> cancelCheckIn(String reservationId) async {
    return _call('cancelCheckIn', {'reservationId': reservationId});
  }

  /// Cancel an on-going check-out.
  Future<void> cancelCheckOut(String reservationId) async {
    return client.cancelCheckOut(reservationId);
  }

  /// Confirm a payment
  Future<Map> confirmPayment(String reservationId, {String paymentMethodId}) async {
    final params = {'reservationId': reservationId};
    if (paymentMethodId != null) params['paymentMethodId'] = paymentMethodId;
    return _call('confirmPayment', params);
  }

  /// Request check-out
  Future<Map> requestCheckOut(String reservationId) async {
    final params = {'reservationId': reservationId};
    return _call('requestCheckOut', params);
  }

  /// Get a stripe ephemeral key
  Future<String> getEphemeralKey(String apiVersion) async {
    final result = await _call('getEphemeralKey', {'stripeversion': apiVersion});
    final key = result['key'];
    final jsonKey = json.encode(key);
    return jsonKey;
  }

  Stream<StripeData> getCurrentUserStripeId() {
    return client.getCurrentUser().map((item) => StripeData(item['stripeId']));
  }

  /// Confirm a payment
  Future<Map> confirmCheckIn(String reservationId) async {
    final params = {'reservationId': reservationId};
    return _call('confirmCheckIn', params);
  }

  /// Confirm a payment
  Future<Map> confirmCheckOut(String reservationId) async {
    final params = {'reservationId': reservationId};
    return _call('confirmCheckOut', params);
  }

  Future<Map> createSetupIntent(String paymentMethod) {
    final params = {'payment_method': paymentMethod};
    return _call('createSetupIntent', params);
  }
}
