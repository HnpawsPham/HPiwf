import "package:cloud_firestore/cloud_firestore.dart";
import '../config.dart';

class FirebaseDB {
  static final FirebaseDB _instance = FirebaseDB._internal();
  factory FirebaseDB() => _instance;
  FirebaseDB._internal();

  static CollectionReference _GIDPrefix(String collection) {
    return FirebaseFirestore.instance.collection(GID).doc("data").collection(collection);
  }

  static Stream<QuerySnapshot> getDBStream(String collection) {
    return _GIDPrefix(collection).snapshots();
  }

  static void getData(String collection) async {
    QuerySnapshot res = await _GIDPrefix(collection).get();
    if (res.docs.isNotEmpty)
      for (var doc in res.docs) print(doc.data());
    else
      print("collection doesnt exist or empty");
  }

  static void addData(String collection, Map<String, dynamic> data) async {
    await _GIDPrefix(collection).add(data);
  }

  static void updateData(String collection, Map<String, dynamic> data) async {
    await _GIDPrefix(collection).doc("info").set(data, SetOptions(merge: true));
  }

  static void addNewUser(String userID, Map<String, dynamic> userData) async {
    await _GIDPrefix("users").doc(userID).set(userData, SetOptions(merge: true));
  }

  static void updateUser(String userID, Map<String, dynamic> userData) async {
    await _GIDPrefix("users").doc(userID).set(userData, SetOptions(merge: true));
  }

  static void getUserData(String userID) async {
    DocumentSnapshot res = await _GIDPrefix("users").doc(userID).get();

    if (res.exists)
      print(res.data());
    else
      print("No user exists");
  }
}
