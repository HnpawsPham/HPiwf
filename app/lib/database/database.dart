import "package:cloud_firestore/cloud_firestore.dart";

class FirebaseDB {
  static final FirebaseDB _instance = FirebaseDB._internal();
  factory FirebaseDB() => _instance;
  FirebaseDB._internal();

  static void getData(String collection) async {
    dynamic res = await FirebaseFirestore.instance.collection(collection).get();
    if (res.exists)
      print(res.data());
    else
      print("Collection doesn't exist");
  }

  static void addNewUser(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection("users").add(userData);
  }

  static void updateUser(String userID, Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection("users").doc(userID).set(userData);
  }

  static void getUserData(String userID) async {
    dynamic res = await FirebaseFirestore.instance.collection("users").doc(userID).get();

    if (res.exists)
      print(res.data());
    else
      print("No user exists");
  }
}
