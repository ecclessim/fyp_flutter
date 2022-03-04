import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepo {
  FirebaseStorage storage = FirebaseStorage.instance;
  Future<String> uploadProfileImage(File filePath, String uid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uploadTask =
          await storage.ref('profile_images/$uid').putFile(filePath);
      var imageUrl = await (uploadTask).ref.getDownloadURL();
      String url = imageUrl.toString();
      print("uploadProfileImage: => Caching profile image");
      prefs.setString("profile_image_$uid", url);
      return url;
    } on FirebaseException catch (e) {
      throw new Exception(e.message);
    }
  }

  Future<dynamic> getProfileImage(uid) async {
    try {
      String url = "";
      await storage
          .ref('profile_images/$uid')
          .getDownloadURL()
          .then((value) => url = value.toString());
      print("Retrieved image: $url");
      return url;
    } on FirebaseException catch (e) {
      print("Exception: $e");
      // throw new Exception(e.message);
      return null;
    }
  }
}
