import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/models/user_model.dart';
import 'package:fyp_flutter/screens/new_stock_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPortfolioScreen extends StatefulWidget {
  final ticker;
  SelectPortfolioScreen({this.ticker});
  @override
  _SelectPortfolioScreenState createState() => _SelectPortfolioScreenState();
}

class _SelectPortfolioScreenState extends State<SelectPortfolioScreen> {
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
    return AlertDialog(
      backgroundColor: Colors.grey[100],
      title: Text('Select Portfolio'),
      insetPadding: EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: ListView.builder(
            itemCount: portfolios.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(0),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      portfolios[index]['portfolioName'],
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      selectedPortfolio = portfolios[index]['portfolioName'];
                      Navigator.of(context).pop();
                      showAddNewStockDialog(
                          context, widget.ticker, selectedPortfolio);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future showAddNewStockDialog(BuildContext context, ticker, portfolioName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewStockScreen(
              ticker: ticker, selectedPortfolio: portfolioName);
        });
  }
}
