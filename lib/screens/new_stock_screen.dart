import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:intl/intl.dart';

class NewStockScreen extends StatefulWidget {
  final ticker;
  final selectedPortfolio;
  NewStockScreen({this.ticker, this.selectedPortfolio});

  @override
  _NewStockScreenState createState() => _NewStockScreenState();
}

class _NewStockScreenState extends State<NewStockScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tickerController = TextEditingController();
  TextEditingController _purchaseDateController = TextEditingController();
  TextEditingController _purchasePriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.ticker != null) {
      _tickerController.text = widget.ticker.toString().toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Stock to ${widget.selectedPortfolio}",
          overflow: TextOverflow.ellipsis),
      insetPadding: EdgeInsets.all(20),
      content: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Colors.red,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextFormField(
                        controller: _tickerController,
                        decoration: InputDecoration(
                          labelText: 'Stock Ticker',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter ticker name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Number of shares',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter number of shares';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                        keyboardType: TextInputType.number,
                        controller: _purchasePriceController,
                        decoration: InputDecoration(
                          labelText: 'Purchase Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter purchase price';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: TextFormField(
                        readOnly: true,
                        controller: _purchaseDateController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.date_range_rounded),
                          labelText: 'Purchase Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter purchase date';
                          }
                          return null;
                        },
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        child: Text(
                          "ADD STOCK",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a Snackbar.
                            bool uploadSuccess = await FireStoreRepo()
                                .addStockToPortfolio(
                                    widget.selectedPortfolio,
                                    _tickerController.text.toUpperCase(),
                                    double.parse(_purchasePriceController.text),
                                    int.parse(_quantityController.text),
                                    _purchaseDateController.text);
                            if (uploadSuccess) {
                              HelperMethods.showSnackBar(context,
                                  "Stock added: ${_tickerController.text}");
                              Navigator.of(context).pop();
                            } else {
                              HelperMethods.showSnackBar(
                                  context, "Error adding stock...");
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: selectedDate);
    if (picked != null && picked != selectedDate)
      setState(() {
        _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }
}
