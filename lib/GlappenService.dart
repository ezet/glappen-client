import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobelappen/main.dart';

class GlappenService {
  GarderobelClient client;
  CloudFunctions cf;

  GlappenService(this.client, this.cf);

  Future<Map<String, dynamic>> requestCheckIn(String paymentMethodId) async {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'requestCheckIn',
    );
    try {
      final result = await callable.call({'paymentMethodId': paymentMethodId});
      return result.data;
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Future<String> confirmPayment(
      String paymentIntentId, String paymentMethodId) async {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'requestCheckIn',
    );
    try {
      final result = await callable.call({'paymentMethodId': paymentMethodId});
      final url = result.data['action']['redirect_to_url']['url'];
      return url;
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
      final result = await callable.call({apiVersion: apiVersion});
      return result.data['key'];
    } on CloudFunctionsException catch (e) {
      log(e.message);
      return null;
    }
  }

  Stream<StripeData> getCurrentUserStripeId() {
    return client.getCurrentUser().map((item) => StripeData(item['stripeId']));
  }
}
