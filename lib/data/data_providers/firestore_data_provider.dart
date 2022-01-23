import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pics/data/models/pic.dart';
import 'package:pics/data/models/user.dart';

class FirestoreDataProvider {
  final CollectionReference _usersCollectionReference = FirebaseFirestore.instance.collection('users');

  Future<List<DocumentSnapshot>> fetchPics(String userId) async {
    var collectionName = "users/${userId.toString()}/pics";
    var collection = FirebaseFirestore.instance.collection(collectionName);
    return (await collection.orderBy("ts", descending: true).get()).docs;
  }

  Future<List<DocumentSnapshot>> fetchNextPics(DocumentSnapshot lastDocument, String userId) async {
    var collectionName = "users/${userId.toString()}/pics";
    var collection = FirebaseFirestore.instance.collection(collectionName);
    return (await collection.orderBy("ts", descending: true).startAfterDocument(lastDocument).limit(10).get()).docs;
  }

  Future addPic(String userId, Pic pic) async {
    var collectionName = "users/${userId.toString()}/pics";
    var collection = FirebaseFirestore.instance.collection(collectionName);
    await collection.add(pic.toJson());
  }

  Future deletePic(String userId, Pic pic) async {
    var collectionName = "users/${userId.toString()}/pics";
    var collection = FirebaseFirestore.instance.collection(collectionName);
    await collection.doc(pic.id).delete();
  }

  Future createUser(User user) async {
    await _usersCollectionReference.doc(user.id).set(user.toJson());
  }

  Future getUser(String uid) async {
    var userData = await _usersCollectionReference.doc(uid).get();
    return User.fromData(userData.data() as Map<String, dynamic>);
  }
}
