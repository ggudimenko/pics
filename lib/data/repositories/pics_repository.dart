import 'dart:io';

import 'package:pics/data/data_providers/firestore_data_provider.dart';
import 'package:pics/data/models/pic.dart';

class PicsRepository {
  final FirestoreDataProvider firestoreDataProvider = FirestoreDataProvider();

  //todo должна быть проверка на уровне бд добавление картини не себе и не авторизованному
  Future<void> addPic(String uid, Pic pic) async {
    await firestoreDataProvider.addPic(uid, pic);
  }

  Future<void> removePic(String uid, Pic pic) async {
    await firestoreDataProvider.deletePic(uid, pic);
  }

  Future<List<Pic>> fetchPics(String uid) async {
    print(uid);
    var documentList = await firestoreDataProvider.fetchPics(uid);
    var pics = documentList.map((e) => Pic.fromData(e.id, e.data() as Map<String, dynamic>)).toList();
    return pics;
  }
}
