import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:garderobel_api/garderobel_client.dart';

class GlappenService {
  GarderobelClient client;
  CloudFunctions cf;

  GlappenService(this.client, this.cf);

  Future<String> createPaymentIntent(String paymentMethodId) async {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'requestPaymentIntent',
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

  Future<String> createEphemeralKey(String apiVersion) async {
//    final url =
//        'https://api.example/generate-ephemeral-key?api_version=$apiVersion';
//    print(url);
//
//    final response = await http.get(
//      url,
//      headers: _getHeaders(accessToken: _accessToken),
//    );
//
//    final d = json.decode(response.body);
//    print(d);
//    if (response.statusCode == 200) {
//      final key = json.encode(d['data']);
//      return key;
//    } else {
//      throw Exception('Failed to get token');
//    }
  }
}
