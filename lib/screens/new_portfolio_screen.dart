import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:intl/intl.dart';

class NewPortfolioScreen extends StatefulWidget {
  @override
  _NewPortfolioScreenState createState() => _NewPortfolioScreenState();
}

class _NewPortfolioScreenState extends State<NewPortfolioScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _portfolioController = TextEditingController();
  TextEditingController _portfolioDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Portfolio"),
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
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: TextFormField(
                      controller: _portfolioController,
                      decoration: InputDecoration(
                        labelText: 'Portfolio Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter portfolio name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: TextFormField(
                      readOnly: true,
                      controller: _portfolioDateController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.date_range_rounded),
                        labelText: 'Portfolio Start Date',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please set a date for portfolio';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton(
                      child: Text(
                        "CREATE PORTFOLIO",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a Snackbar.
                          bool uploadSuccess =
                              await FireStoreRepo().createPortfolio(
                            _portfolioController.text,
                            _portfolioDateController.text,
                          );
                          if (uploadSuccess) {
                            HelperMethods.showSnackBar(context,
                                "Portfolio Created: ${_portfolioController.text}");
                            Navigator.of(context).pop();
                          } else {
                            HelperMethods.showSnackBar(context,
                                "Portfolio under the name ${_portfolioController.text} already exists");
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime selectedDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    DateTime customTime =
        DateTime(currentTime.year - 1, currentTime.month, currentTime.day);
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: customTime,
        firstDate: DateTime(1900, 1),
        lastDate: customTime);
    if (picked != null && picked != selectedDate)
      setState(() {
        _portfolioDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }
}
