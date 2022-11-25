import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

UploadTask uploadImage(File image, String? email) {
  final extension = p.extension(image.path);
  final Reference ref =
      FirebaseStorage.instanceFor(bucket: 'your_storage_Bucket')
          .ref()
          .child('$email$extension');
  UploadTask uploadTask = ref.putFile(image);
  return uploadTask;
}
