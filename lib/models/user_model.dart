// import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String? uid;
  String? email;
  String? username;
  String? avatarUrl;

  UserModel({this.uid, this.email, this.username, this.avatarUrl});

  // get data FROM server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'], email: map['email'], username: map['username']);
  }

  // send data TO server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }
}
