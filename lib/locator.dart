import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:garderobel_api/garderobel_api.dart';

GetIt getLocator(BuildContext context) {
  GetIt locator = GetIt();
  locator.registerLazySingleton<Firestore>(() => Firestore.instance);
  locator.registerLazySingleton<GarderobelApi>(() => LocalGarderobelApi(locator.get()));
  return locator;
}
