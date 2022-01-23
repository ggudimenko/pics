import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  Timestamp ts;
  String id;

  User({required this.ts, required this.id});

  User.fromData(Map<String, dynamic> data)
      : ts = data['ts'],
        id = data['id'];

  Map<String, dynamic> toJson() {
    return {'ts': ts, 'id': id};
  }
}
