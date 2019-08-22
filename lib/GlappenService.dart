import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobelappen/main.dart';

class GlappenService {
  GarderobelClient client;
  CloudFunctions cf;

  GlappenService(this.client, this.cf);

  Future<Map> requestCheckIn(String paymentMethodId) async {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'requestCheckIn',
    );
    try {
      final result = await callable
          .call({'paymentMethodId': paymentMethodId, 'returnUrl': 'stripesdk://3ds.stripesdk.io'});
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Future<Map> confirmPayment(String reservationId, {String paymentMethodId}) async {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'confirmPayment',
    );
    try {
      final params = {'reservation': reservationId};
      if (paymentMethodId != null) params['paymentMethodId'] = paymentMethodId;

      final result = await callable.call(params);
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Future<String> getEphemeralKey(String apiVersion) async {
    final callable = cf.getHttpsCallable(
      functionName: 'getEphemeralKey',
    );
    try {
      final result = await callable.call({'stripeversion': apiVersion});
      final key = result.data['key'];
      final jsonKey = json.encode(key);
      return jsonKey;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Future<Map> createPaymentMethod(String paymentMethodId) async {
    final callable = cf.getHttpsCallable(
      functionName: 'addPaymentMethod',
    );
    try {
      final result = await callable.call({'paymentMethodId': paymentMethodId});
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Stream<StripeData> getCurrentUserStripeId() {
    return client.getCurrentUser().map((item) => StripeData(item['stripeId']));
  }
}
