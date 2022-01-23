import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageService {
  Future<UploadTask> uploadImage({
    required File imageToUpload,
  }) async {
    var imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageFileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);
    return Future.value(uploadTask);
  }

  Future deleteImage(String imageFileName) async {
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageFileName);
    await firebaseStorageRef.delete();
  }
}

class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;

  CloudStorageResult({required this.imageUrl, required this.imageFileName});
}
