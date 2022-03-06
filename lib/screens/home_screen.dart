import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/firebase_controller/storage_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/user_model.dart';
import 'package:fyp_flutter/screens/new_portfolio_screen.dart';
import 'package:fyp_flutter/screens/portfolio_screen.dart';
import 'package:fyp_flutter/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  List<dynamic> portfolios = [];
  @override
  void initState() {
    

    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      setState(() {
        this.loggedInUser = UserModel.fromMap(value.data());
        _loadSharedPreferences();
      });
    });
    _getPortfolioNames();
    setState(() {
      print("Refreshing state");
    });
    super.initState();
  }

  Future<void> _loadSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      String? imgUrl = prefs.getString("profile_image_${user!.uid}");
      if (imgUrl != null) {
        print("loading profile image from cache.");
        setState(() {
            this.loggedInUser.avatarUrl = imgUrl;  
        });
      } else {
        await StorageRepo()
            .getProfileImage(user?.uid)
            .then((value) => setState(() {
                  prefs.setString("profile_image_${user!.uid}", value);
                  print("Cache not found: Setting avatar to $value");
                  this.loggedInUser.avatarUrl = value;
                }));
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _getPortfolioNames() async {
    await FireStoreRepo().getPortfolioNames().then((value) {
      setState(() {
        this.portfolios = value;
        for (var i = 0; i < this.portfolios.length; i++) {
          var pfValue = this.portfolios[i]['portfolioValue'];
          String convertedValue = HelperMethods.numberCommafy(
              HelperMethods.centsToDollars(pfValue.round()).toString());
          pfValue = convertedValue;
        }
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          leading: IconButton(
            icon: loggedInUser.avatarUrl == null
                ? CircleAvatar(child: Icon(Icons.person))
                : CircleAvatar(
                    backgroundImage: NetworkImage(loggedInUser.avatarUrl!),
                  ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
          title: Column(
            children: [
              Text(
                "Hello, ${loggedInUser.username}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              portfolios.length > 0
                  ? Text(
                      "Showing all created portfolios",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                      ),
                    )
                  : Text(
                      "Welcome to Momo Manager",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
          centerTitle: true,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 25),
          child: FloatingActionButton(
            mini: true,
            elevation: 0,
            onPressed: () async {
              await showNewPortfolioDialog(context);
              _getPortfolioNames();
            },
            child: Icon(Icons.add),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 15,
                ),
                portfolios.length == 0
                    ? Container(
                        height: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Center(
                            child: Text(
                                "No portfolios yet.\nCreate your first portfolio by tapping the + button",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(fontSize: 18)),
                          ),
                        ),
                      )
                    : Container(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: portfolios.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 8),
                              child: Dismissible(
                                key: Key(portfolios[index]['portfolioName']),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: Text("Confirm"),
                                          content: Text(
                                              "Are you sure you want to delete this portfolio?"),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () async {
                                                  await FireStoreRepo()
                                                      .deletePortfolio(
                                                          portfolios[index][
                                                              'portfolioName']);
                                                  HelperMethods.showSnackBar(
                                                      context,
                                                      "Deleted portfolio");
                                                  _getPortfolioNames();
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: const Text("DELETE")),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ]);
                                    },
                                  );
                                },
                                background: Container(
                                  color: Colors.red,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 32.0),
                                        child: Icon(Icons.delete,
                                            color: Colors.white),
                                      )),
                                ),
                                child: Container(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    elevation: 2,
                                    color: Colors.blueAccent,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      title: Text(
                                        portfolios[index]['portfolioName'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Total: \$${HelperMethods.numberCommafy(HelperMethods.centsToDollars(portfolios[index]['portfolioValue'].round()).toString())}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PortfolioScreen(
                                                      currentPortfolio:
                                                          portfolios[index]
                                                              ['portfolioName'],
                                                      portfolioPrincipal:
                                                          portfolios[index][
                                                              'portfolioValue'],
                                                      uid: loggedInUser.uid,
                                                    )));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ));
  }

  Future showNewPortfolioDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewPortfolioScreen();
        });
  }
}
