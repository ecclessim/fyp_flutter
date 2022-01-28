import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:google_fonts/google_fonts.dart';

class StockRecordsScreen extends StatefulWidget {
  final currentPortfolio;
  final selectedTicker;
  StockRecordsScreen({this.currentPortfolio, this.selectedTicker});
  @override
  _StockRecordsScreenState createState() => _StockRecordsScreenState();
}

class _StockRecordsScreenState extends State<StockRecordsScreen> {
  List<dynamic> stockRecords = [];
  double averageSharePrice = 0.0;

  @override
  void initState() {
    super.initState();
    FireStoreRepo()
        .getStockRecords(widget.currentPortfolio, widget.selectedTicker)
        .then((value) {
      setState(() {
        stockRecords = value;
        averageSharePrice = getAvgSharePrice(stockRecords);
      });
    });
  }

  double getAvgSharePrice(List<dynamic> stockRecords) {
    // get sum of purchasePrice * shares
    // get sum of shares
    // get average share price as totalPurchasePrice / totalShares
    double totalAssetValue = 0;
    double totalShares = 0;
    stockRecords.forEach((element) {
      totalAssetValue += element['purchasePrice'] * element['noOfShares'];
      print("$totalAssetValue");
      totalShares += element['noOfShares'];
    });
    print("$totalAssetValue $totalShares");
    return double.parse((totalAssetValue / totalShares).toStringAsFixed(3));
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
                      blurRadius: 50,
                      spreadRadius: 2,
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
                              "Stock records for ${widget.selectedTicker}",
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
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
              SizedBox(
                height: 15,
              ),
              ListView.builder(
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(stockRecords[index].toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete"),
                                content: Text(
                                    "Are you sure you want to delete this stock record?"),
                                actions: [
                                  TextButton(
                                    child: Text("Yes"),
                                    onPressed: () async {
                                      await FireStoreRepo()
                                          .deleteStockRecord(
                                              widget.currentPortfolio,
                                              widget.selectedTicker,
                                              stockRecords[index])
                                          .then((value) {
                                        setState(() {
                                          stockRecords.removeAt(index);
                                          HelperMethods.showSnackBar(
                                              context, "Stock record deleted");
                                        });
                                      });
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                  TextButton(
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      background: Container(
                        color: Colors.red,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 32.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            )),
                      ),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: Text(
                            "\$${stockRecords[index]['purchasePrice'].toString()}",
                            style: GoogleFonts.roboto(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            "${stockRecords[index]['noOfShares'].toString()} shares",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                            ),
                          ),
                          trailing: Text(
                            stockRecords[index]['purchaseDate'].toString(),
                            style: GoogleFonts.roboto(
                                fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: stockRecords.length,
                  shrinkWrap: true),
              // Padding(
              //   padding: const EdgeInsets.only(top: 12.0),
              //   child: Container(
              //     height: 300,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(15),
              //       color: Colors.amber,
              //     ),
              //     child: Center(
              //       child: Text("$averageSharePrice"),
              //     ),
              //   ),
              // ),
            ]))),
      ),
    );
  }
}
