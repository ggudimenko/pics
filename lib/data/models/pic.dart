import 'package:cloud_firestore/cloud_firestore.dart';

class Pic {
  Timestamp ts;
  String url;
  String id;

  Pic({required this.url, required this.ts, required this.id});

  Pic.fromData(this.id, Map<String, dynamic> data)
      : ts = data['ts'],
        url = data['url'];

  Map<String, dynamic> toJson() {
    return {'ts': ts, 'url': url};
  }
}
