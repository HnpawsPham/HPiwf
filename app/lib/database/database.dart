import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import '../config.dart';
import "authentication.dart";

class FirebaseDB {
  static final FirebaseDB _instance = FirebaseDB._internal();
  factory FirebaseDB() => _instance;
  FirebaseDB._internal();

  static ValueNotifier<String> chosenGID = ValueNotifier<String>("");

  static void initGIDListener(FirebaseAuth authInstance) {
    authInstance.authStateChanges().listen((user) {
      if (user == null) {
        chosenGID.value = "";
        return;
      }

      FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          chosenGID.value = data['GID'] ?? "";
          print("GID loaded successfully: ${chosenGID.value}");
        } else
          chosenGID.value = "";
      });
    });
  }

  static CollectionReference _GIDPrefix(String collection) {
    return FirebaseFirestore.instance
        .collection(chosenGID.value)
        .doc("data")
        .collection(collection);
  }

  static Stream<QuerySnapshot> getDBStream(String collection) {
    return FirebaseFirestore.instance
        .collection(chosenGID.value)
        .doc("data")
        .collection(collection)
        .snapshots();
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
    await FirebaseFirestore.instance.doc(userID).set(userData, SetOptions(merge: true));
  }

  static void updateUser(String userID, Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .set(userData, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot?> getUserDataStream(String userID) {
    print(FirebaseFirestore.instance.collection("users").doc(userID).snapshots());
    return FirebaseFirestore.instance.collection("users").doc(userID).snapshots();
  }
}
