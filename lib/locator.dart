import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:garderobel_api/garderobel_client.dart';
import 'package:garderobelappen/GlappenService.dart';
import 'package:get_it/get_it.dart';
import 'package:stripe_api/stripe_api.dart';

GetIt locator = GetIt();

GetIt getLocator() {
  locator.registerLazySingleton<Firestore>(() => Firestore.instance);
  locator.registerLazySingleton<GarderobelClient>(() => GarderobelClient(locator.get()));
  locator.registerLazySingleton(() => CloudFunctions(region: "europe-west2"));
  locator.registerLazySingleton(() => GlappenService(locator.get(), locator.get()));
  locator.registerLazySingleton<Stripe>(() {
    Stripe.init('pk_test_gTROf276lYisD9kQGxPeHOtJ00dT2FrK47');
    return Stripe.instance;
  });
  return locator;
}
