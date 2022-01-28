import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/models/user_model.dart';
import 'package:fyp_flutter/screens/OptimisationResultScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioOptSelectionScreen extends StatefulWidget {
  final functionName;
  final label;
  PortfolioOptSelectionScreen({this.functionName, this.label});

  @override
  _PortfolioOptSelectionScreenState createState() =>
      _PortfolioOptSelectionScreenState();
}

class _PortfolioOptSelectionScreenState
    extends State<PortfolioOptSelectionScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  List<dynamic> portfolios = [];
  String selectedPortfolio = "";
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    FireStoreRepo().getPortfolioNames().then((value) {
      setState(() {
        this.portfolios = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Container(
                width: 100,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(15, 12, 15, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: ListTile(
                            title: Text(
                              "Select a portfolio",
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListTile(
                        dense: true,
                        minLeadingWidth: 0,
                        contentPadding: EdgeInsets.all(3),
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          "${widget.label}",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  child: portfolios.length > 0
                      ? ListView.builder(
                          itemCount: portfolios.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                height: 80,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 2,
                                  color: Colors.blueAccent,
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    title: Text(
                                      portfolios[index]['portfolioName'],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      selectedPortfolio =
                                          portfolios[index]['portfolioName'];
                                      showOptimisationResultScreen(
                                          context,
                                          widget.functionName,
                                          selectedPortfolio,
                                          widget.label);
                                    },
                                  ),
                                ),
                              ),
                            );
                          })
                      : Container(
                          height: 400,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text("No Portfolios Available"),
                          ),
                        ))
            ])),
      ),
    ));
  }

  Future showOptimisationResultScreen(BuildContext context, String functionName,
      String portfolioName, String label) async {
    Navigator.of(context).pop();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return OptimisationResultScreen(
              functionName: functionName,
              portfolioName: portfolioName,
              label: label);
        });
  }
}
