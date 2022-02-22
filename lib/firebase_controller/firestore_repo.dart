import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/portfolio_model.dart';
import 'package:fyp_flutter/models/stock_model.dart';
// import 'package:fyp_flutter/webservices/web_services.dart';
// import 'package:decimal/decimal.dart';

// Create portfolio
// Get user portfolios
// Get portfolio stocks
// Add stock into portfolio
// Modify existing stock information
// Delete stock from portfolio
// Delete portfolio

class FireStoreRepo {
  final auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<bool> checkDocExists(String docId) async {
    try {
      // final _auth = FirebaseAuth.instance;
      // FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User? user = auth.currentUser;
      var collectionRef = firebaseFirestore.collection('users').doc(user!.uid);
      var doc = await collectionRef.collection('portfolio').doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<List> getPortfolioNames() async {
    User? user = auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('portfolio');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    // print("FETCHED PORTFOLIO DATA");
    // print(allData);
    return allData;
  }

  Future<String> getPortfolioDate(String portfolioName) async {
    User? user = auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('portfolio');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef
        .where("portfolioName", isEqualTo: portfolioName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get("createdDate");
    } else {
      return "";
    }
  }

  Future<double> getPortfolioValue(String portfolioName) async {
    User? user = auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('portfolio');
    // Get docs from collection reference
    QuerySnapshot query = await _collectionRef
        .where("portfolioName", isEqualTo: portfolioName)
        .get();

    // get data from firestore and return portfolioValue
    if (query.docs.isNotEmpty) {
      double portfolioValue = query.docs.first.get("portfolioValue");
      return HelperMethods.centsToDollars(portfolioValue.round());
    } else {
      return 0.0;
    }
  }

  Future<bool> addStockToPortfolio(String portfolioName, String ticker,
      double purchasePrice, int amount, String purchaseDate) async {
    //Add stock into firestore collection under portfolioName
    User? user = auth.currentUser;
    StockModel stockModel = StockModel(
      ticker: ticker,
      purchasePrice: purchasePrice,
      noOfShares: amount,
      purchaseDate: purchaseDate,
    );
    try {
      final totalValue =
          double.parse((amount * purchasePrice).toStringAsFixed(2));
      final storeTotalValue = HelperMethods.dollarsToCents(totalValue);
      print("addStockToPortfolio: $totalValue, $storeTotalValue");

      // adding stock info to collection
      await firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection('portfolio')
          .doc(portfolioName)
          .collection('stocks')
          .doc()
          .set(stockModel.toMap());
      // updating totalAssetValue in weights
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc(portfolioName)
          .collection('weights')
          .doc(ticker)
          .set({
        'ticker': ticker,
        'totalAssetValue': FieldValue.increment(storeTotalValue),
      }, SetOptions(merge: true));
      // updating portfolio value
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc(portfolioName)
          .update({'portfolioValue': FieldValue.increment(storeTotalValue)});
      // update stock weights relative to portfolio value

      return true;
    } catch (e) {
      print("FireStoreRepo: addStockToPortfolio: " + e.toString());
      return false;
    }
    // Get docs from collection reference
  }

  // Get unique stock ticker under a portfolio
  Future<List> getUniqueStockTicker(String portfolioName) async {
    User? user = auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('portfolio')
        .doc(portfolioName)
        .collection('stocks');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final tickers =
        querySnapshot.docs.map((doc) => doc.get("ticker")).toSet().toList();
    print("FETCHED UNIQUE TICKERS");
    print(tickers);
    return tickers;
  }

  //update user username and/or password
  Future<bool> updateUser(
      String? username, String? oldPassword, String? password) async {
    User? user = auth.currentUser;
    try {
      // case where only username needs change, update username only
      // case where only password needs change, update password only
      // case where both username and password needs change, update both
      if (username != "" && password == "") {
        await firebaseFirestore.collection('users').doc(user!.uid).update({
          'username': username,
        });
      } else if (username == "" && password != "") {
        var credential = EmailAuthProvider.credential(
            email: user!.email!, password: oldPassword!);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(password!);
      } else if (username != "" && password != "") {
        await firebaseFirestore.collection('users').doc(user!.uid).update({
          'username': username,
        });
        var credential = EmailAuthProvider.credential(
            email: user.email!, password: oldPassword!);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(password!);
      }

      return true;
    } catch (e) {
      print("FireStoreRepo: updateUser: " + e.toString());
      return false;
    }
  }

  Future<bool> createPortfolio(
      String portfolioName, String portfolioDate) async {
    //call firestore
    //call portfolioModel
    //send values
    User? user = auth.currentUser;
    PortfolioModel portfolioModel = PortfolioModel(
      portfolioName: portfolioName,
      portfolioValue: 0.0,
      createdDate: portfolioDate,
    );
    bool docExists = await checkDocExists(portfolioName);
    if (!docExists) {
      await firebaseFirestore
          .collection("users")
          .doc(user!.uid)
          .collection("portfolio")
          .doc(portfolioName)
          .set(portfolioModel.toMap());
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deletePortfolio(portfolio) async {
    User? user = auth.currentUser;
    try {
      await firebaseFirestore
          .collection("users")
          .doc(user!.uid)
          .collection("portfolio")
          .doc(portfolio)
          .collection("stocks")
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .collection("portfolio")
          .doc(portfolio)
          .collection("weights")
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .collection("portfolio")
          .doc(portfolio)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List> getStockRecords(String portfolioName, String stock) async {
    User? user = auth.currentUser;
    print("searching for $stock");
    QuerySnapshot query = await firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection("portfolio")
        .doc(portfolioName)
        .collection("stocks")
        .where("ticker", isEqualTo: stock)
        .get();
    if (query.docs.length == 0) {
      print("no stock records found");
      return [];
    } else {
      print("found stock records");
      return query.docs.map((doc) => doc.data()).toList();
    }
  }

  Future<bool> deleteStockRecord(
      String currentPortfolio, String selectedTicker, stockRecord) async {
    User? user = auth.currentUser;
    try {
      print("deleteStockRecord: $stockRecord");
      print("$currentPortfolio");
      print("$selectedTicker");
      print("deleteStockRecord: ${stockRecord["purchaseDate"]}");
      print("deleteStockRecord: ${stockRecord["totalValue"]}");
      QuerySnapshot query = await firebaseFirestore
          .collection("users")
          .doc(user!.uid)
          .collection("portfolio")
          .doc(currentPortfolio)
          .collection("stocks")
          .where("ticker", isEqualTo: selectedTicker)
          .where("totalValue", isEqualTo: stockRecord["totalValue"])
          .where("purchaseDate", isEqualTo: stockRecord["purchaseDate"])
          .get();

      if (query.docs.length >= 1) {
        print("found stock record to delete");
        final stockValue =
            HelperMethods.dollarsToCents(stockRecord["totalValue"]);
        await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .collection('portfolio')
            .doc(currentPortfolio)
            .update({'portfolioValue': FieldValue.increment(-stockValue)});
        CollectionReference _weightReference = firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .collection('portfolio')
            .doc(currentPortfolio)
            .collection('weights');

        await _weightReference
            .doc(selectedTicker)
            .update({'totalAssetValue': FieldValue.increment(-stockValue)});
        await _weightReference
            .where('totalAssetValue', isEqualTo: 0)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });

        await query.docs.first.reference.delete();
        return true;
      } else {
        print("no stock record found to delete");
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> calculateStockWeights(
      String portfolioName) async {
    print(
        "calculateStockWeights: $portfolioName -------------------------------------------------");
    User? user = auth.currentUser;
    List<Map<String, dynamic>> weights = [];
    double portfolioValue = await firebaseFirestore
        .collection('users')
        .doc(user!.uid)
        .collection('portfolio')
        .doc(portfolioName)
        .get()
        .then((snapshot) => snapshot.data()!['portfolioValue']);
    CollectionReference _weightReference = firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('portfolio')
        .doc(portfolioName)
        .collection('weights');
    //loop through each totalAssetValue and calculate weight against portfolioValue
    await _weightReference.get().then((snapshot) {
      double value = 0;
      snapshot.docs.forEach((doc) {
        String ticker = doc.get('ticker');
        double weight = doc.get('totalAssetValue') / portfolioValue;
        String weightPct = (weight * 100).toStringAsFixed(2);
        value += weight;
        print("$ticker, $weightPct%, $value");
        weights.add({"ticker": ticker, "weight": weight});
      });
      print(
          "calculateStockWeights: END DEBUG -------------------------------------------------");
    });
    return weights;
  }
}
