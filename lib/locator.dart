import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

GetIt getLocator(BuildContext context) {
  GetIt locator = GetIt();
  locator.registerLazySingleton<Firestore>(() => Firestore.instance);
//  locator.registerLazySingleton<GladminApi>(() => LocalGladminApi(locator.get()));
  return locator;
}
