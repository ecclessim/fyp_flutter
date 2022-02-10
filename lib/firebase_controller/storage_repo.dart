import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepo {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File filePath, String uid) async {
    try {
      var uploadTask =
          await storage.ref('profile_images/$uid').putFile(filePath);
      var imageUrl = await (uploadTask).ref.getDownloadURL();
      String url = imageUrl.toString();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      throw new Exception(e.message);
    }
  }

  Future<dynamic> getProfileImage(uid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = "";
      await storage
          .ref('profile_images/$uid')
          .getDownloadURL()
          .then((value) => url = value.toString());
      print("Retrieved image: $url");
      prefs.setString("profile_image", url);
      return url;
    } on FirebaseException catch (e) {
      print("Exception: $e");
      // throw new Exception(e.message);
      return null;
    }
  }
}
