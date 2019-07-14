library garderobel_api;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

abstract class GarderobelApi {
  Future<DocumentReference> createReservation(String qrCode, String userId);

  Future<List<DocumentSnapshot>> findReservationsForCode(String qrCode, String userId);

  Stream<Iterable<Reservation>> findReservationsForUser(String userId, {bool onlyActive: true});

  Future checkOut(DocumentReference reservation);
}

class LocalGarderobelApi implements GarderobelApi {
  LocalGarderobelApi(this._fireStore) : db = Db(_fireStore);

  // ignore: unused_field
  final Firestore _fireStore;
  final Db db;

  @override
  createReservation(String qrCode, String userId) async {
    final code = _tokenizeCode(qrCode);
    final venue = db.venue(code.venueId);
    final wardrobe = venue.wardrobe(code.wardrobeId);
    final section = wardrobe.section(code.sectionId);
    final hangersRef = section.hangers;

    final currentReservations = await section.findCurrentReservations(userId);
    if (currentReservations.isNotEmpty) return Future.value(null);

    final hangerSnapshot = await section.findAvailableHanger();
    if (hangerSnapshot == null) {
      return Future.value(null);
    }
    final hangerRef = hangerSnapshot.reference;
    hangerRef.setData({
      'state': HangerState.UNAVAILABLE.index,
      'stateUpdated': FieldValue.serverTimestamp(),
    }, merge: true);

    final userRef = db.user(userId);

    final hangerName = await hangerRef.get().then((item) => item.data[HangerRef.fieldId]);
    final userName = await userRef.ref.get().then((item) => item.data[UserRef.fieldName]);

    final venueData = await venue.ref.get();
    final wardrobeData = await wardrobe.ref.get();

    final reservationData = {
      ReservationRef.jsonSection: hangersRef.parent(),
      ReservationRef.jsonHanger: hangerRef,
      ReservationRef.jsonHangerName: hangerName,
      ReservationRef.jsonUser: userRef.ref,
      ReservationRef.jsonVenueName: venueData.data[VenueRef.fieldName],
      ReservationRef.jsonWardrobeName: wardrobeData.data[WardrobeRef.fieldName],
      ReservationRef.jsonUserName: userName,
      ReservationRef.jsonState: ReservationState.CHECKING_IN.index,
      ReservationRef.jsonReservationTime: FieldValue.serverTimestamp(),
    };

    return venue.reservations.add(reservationData);
  }

  @override
  findReservationsForCode(String qrCode, String userId) async {
    final code = _tokenizeCode(qrCode);
    return db
        .venue(code.venueId)
        .wardrobe(code.wardrobeId)
        .section(code.sectionId)
        .findCurrentReservations(userId);
  }

  QrCode _tokenizeCode(String code) {
    return QrCode("aaXt3hxtb5tf8aTz1BNp", "E8blVz5KBFZoLOTLJGf1", "vnEpTisjoygX3UJFaMy2");
  }

  @override
  findReservationsForUser(String userId, {bool onlyActive: true}) {
    return db
        .user(userId)
        .reservations(onlyActive: onlyActive)
        .snapshots()
        .map((qs) => qs.documents.map((ds) => ReservationRef.fromFirestore(ds)));
  }

  @override
  Future checkOut(DocumentReference reservation) {
    return reservation.updateData({
      ReservationRef.jsonState: ReservationState.CHECKING_OUT.index,
      ReservationRef.jsonStateUpdated: FieldValue.serverTimestamp()
    });
  }
}

class QrCode {
  QrCode(this.venueId, this.wardrobeId, this.sectionId);

  final String venueId;
  final String wardrobeId;
  final String sectionId;
}

enum HangerState {
  AVAILABLE,
  UNAVAILABLE,
}

class Collection {
  const Collection(this.ref);

  final CollectionReference ref;
}

class Document {
  const Document(this.ref);

  final DocumentReference ref;
}

class UserRef extends Document {
  UserRef(DocumentReference ref) : super(ref);
  static const fieldName = 'name';

  Query reservations({@required bool onlyActive}) {
    final query = ref.firestore
        .collectionGroup(VenueRef.pathReservations)
        .where(ReservationRef.jsonUser, isEqualTo: ref);

    return onlyActive
        ? query
            .where(ReservationRef.jsonState,
                isGreaterThanOrEqualTo: ReservationState.CHECKED_IN.index)
            .orderBy(ReservationRef.jsonState, descending: true)
            .orderBy(ReservationRef.jsonReservationTime)
        : query.orderBy(ReservationRef.jsonCheckOut, descending: true);
  }
}

class ReservationRef extends Document {
  ReservationRef(DocumentReference ref) : super(ref);

  static const jsonReservationTime = 'reservationTime';
  static const jsonStateUpdated = 'stateUpdated';
  static const jsonCheckIn = 'checkedIn';
  static const jsonCheckOut = 'checkedOut';
  static const jsonHanger = 'hanger';
  static const jsonVenueName = 'venueName';
  static const jsonWardrobeName = 'wardrobeName';
  static const jsonHangerName = 'hangerName';
  static const jsonSection = 'section';
  static const jsonUser = 'user';
  static const jsonUserName = 'userName';
  static const jsonPayment = 'payment';
  static const jsonState = 'state';

  static Reservation fromFirestore(DocumentSnapshot ds) {
    final data = ds.data;
    return Reservation(
        ref: ds.reference,
        docId: ds.documentID,
        checkIn: data[ReservationRef.jsonCheckIn],
        checkOut: data[ReservationRef.jsonCheckOut],
        stateUpdated: data[ReservationRef.jsonStateUpdated],
        state: ReservationState.values[data[ReservationRef.jsonState] ?? 1],
        reservationTime: data[ReservationRef.jsonReservationTime],
        hanger: data[ReservationRef.jsonHanger],
        venueName: data[ReservationRef.jsonVenueName],
        wardrobeName: data[ReservationRef.jsonWardrobeName],
        section: data[ReservationRef.jsonSection],
        user: data[ReservationRef.jsonUser],
        userName: data[ReservationRef.jsonUserName],
        hangerName: data[ReservationRef.jsonHangerName],
        payment: data[ReservationRef.jsonPayment]);
  }
}

class HangerRef extends Document {
  HangerRef(DocumentReference ref) : super(ref);

  static const fieldId = 'id';
}

class SectionRef extends Document {
  static const String pathHangers = 'hangers';

  SectionRef(DocumentReference ref) : super(ref);

  CollectionReference get hangers => ref.collection(pathHangers);

  Future<DocumentSnapshot> findAvailableHanger() async {
    final documents = await hangers
        .where('state', isEqualTo: HangerState.AVAILABLE.index)
        .limit(1)
        .getDocuments();
    if (documents.documents.isEmpty)
      return null;
    else
      return documents.documents.first;
  }

  Future<List<DocumentSnapshot>> findCurrentReservations(String userId) async {
    // TODO
    return Future.value([]);
  }
}

class VenueRef extends Document {
  VenueRef(DocumentReference ref) : super(ref);

  static const pathWardrobes = 'wardrobes';
  static const pathReservations = 'reservations';
  static const fieldName = 'name';

  CollectionReference get wardrobes => ref.collection(pathWardrobes);

  WardrobeRef wardrobe(String id) => WardrobeRef(wardrobes.document(id));

  CollectionReference get reservations => ref.collection(pathReservations);

  ReservationRef reservation(String id) => ReservationRef(reservations.document(id));
}

class WardrobeRef extends Document {
  static const fieldName = 'name';

  WardrobeRef(DocumentReference ref) : super(ref);

  final pathSections = 'sections';

  CollectionReference get sections => ref.collection(pathSections);

  SectionRef section(String sectionId) => SectionRef(sections.document(sectionId));
}

class DeviceRef extends Document {
  DeviceRef(DocumentReference ref) : super(ref);
}

class Db {
  Db(this.db);

  static const pathVenues = 'venues';
  static const pathUsers = 'users';
  static const pathDevices = 'devices';

  final Firestore db;

  CollectionReference get venues => db.collection(pathVenues);

  CollectionReference get users => db.collection(pathUsers);

  CollectionReference get devices => db.collection(pathDevices);

  DeviceRef device(String id) => DeviceRef(devices.document(id));

  VenueRef venue(String id) => VenueRef(venues.document(id));

  UserRef user(String userId) => UserRef(users.document(userId));
}

class Reservation {
  final DocumentReference ref;
  final String docId;
  final String hangerName;
  final String userName;
  final String venueName;
  final String wardrobeName;
  final Timestamp checkIn;
  final Timestamp checkOut;
  final Timestamp reservationTime;
  final Timestamp stateUpdated;
  final ReservationState state;
  final DocumentReference hanger;
  final DocumentReference section;
  final DocumentReference user;
  final DocumentReference payment;

  Reservation(
      {@required this.ref,
      @required this.docId,
      @required this.checkIn,
      @required this.checkOut,
      @required this.reservationTime,
      @required this.hanger,
      @required this.hangerName,
      @required this.section,
      @required this.userName,
      @required this.user,
      @required this.state,
      @required this.venueName,
      @required this.wardrobeName,
      @required this.stateUpdated,
      @required this.payment});
}

enum ReservationState { CHECK_IN_REJECTED, CHECKED_OUT, CHECKED_IN, CHECKING_OUT, CHECKING_IN }
