import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firebase_controller.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/firebase_controller/storage_repo.dart';
import 'package:fyp_flutter/helper_screen/avatar.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final _formkey = GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _oldPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();

  @override
  void initState() {
    var userImage = StorageRepo().getProfileImage(user?.uid);
    userImage.then((value) {
      setState(() {
        loggedInUser.avatarUrl = value;
      });
    });
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      print("Retrieved user data: $value");
      setState(() {
        _usernameController.text = loggedInUser.username!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        //no shadow on appbar
        elevation: 0,
      ),
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Avatar(
                          avatarUrl: loggedInUser.avatarUrl,
                          onTap: () async {
                            var image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              print(image.path);
                              String profileImgUrl = await StorageRepo()
                                  .uploadProfileImage(
                                      File(image.path), user!.uid);
                              setState(() {
                                loggedInUser.avatarUrl = profileImgUrl;
                              });
                              HelperMethods.showSnackBar(context,
                                  "Succesfully uploaded profile picture");
                            }
                          },
                        ),
                      ),
                      Text(
                        "Settings",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(hintText: "Username"),
                        controller: _usernameController,
                      ),
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Manage Password",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "Current Password"),
                                controller: _oldPasswordController,
                              ),
                              TextFormField(
                                obscureText: true,
                                decoration:
                                    InputDecoration(hintText: "New Password"),
                                controller: _newPasswordController,
                              ),
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "Confirm Password"),
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if (value != _newPasswordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  bool updateProfile = await FireStoreRepo()
                                      .updateUser(
                                          _usernameController
                                              .text
                                              .trimLeft()
                                              .trimRight(),
                                          _oldPasswordController.text
                                              .trimLeft()
                                              .trimRight(),
                                          _newPasswordController.text
                                              .trimLeft()
                                              .trimRight());
                                  if (updateProfile) {
                                    HelperMethods.showSnackBar(
                                        context, "Succesfully updated profile");
                                    Navigator.pop(context);
                                    setState(() {
                                      
                                    });
                                  } else {
                                    HelperMethods.showSnackBar(
                                        context, "Failed to update profile");
                                  }
                                }
                              },
                              child: Text("Save Profile"),
                            ),
                            SizedBox(width: 20.0),
                            ElevatedButton(
                              onPressed: () {
                                FirebaseController.logOut(context);
                                Navigator.pop(context);
                              },
                              child: Text("Log Out"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
