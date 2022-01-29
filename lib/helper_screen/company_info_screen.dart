import 'package:flutter/material.dart';
import 'package:fyp_flutter/helper_screen/company_info_row.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyInfoWidget extends StatelessWidget {
  final weekChange52;
  final avgVolume;
  final country;
  final currentPrice;
  final yieldValue;
  final divYield;
  final forwardPE;
  final longSummary;
  final mktCap;
  final open;
  final previousClose;
  final sector;
  final sharesOuts;
  final volume;
  final dailyChange;
  final dailyPctChange;
  CompanyInfoWidget({
    Key? key,
    this.weekChange52,
    this.avgVolume,
    this.country,
    this.currentPrice,
    this.yieldValue,
    this.divYield,
    this.forwardPE,
    this.longSummary,
    this.mktCap,
    this.open,
    this.previousClose,
    this.sector,
    this.sharesOuts,
    this.volume,
    this.dailyChange,
    this.dailyPctChange,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "Open:",
              row1Value: open,
              row2Title: "Previous Close:",
              row2Value: previousClose,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "Market Cap:",
              row1Value: "$mktCap",
              row2Title: "FWD PE:",
              row2Value: "$forwardPE",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "Volume:",
              row1Value: "$volume",
              row2Title: "Avg volume:",
              row2Value: "$avgVolume",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "Div. Yield:",
              row1Value: "$divYield",
              row2Title: "Yield:",
              row2Value: "$yieldValue",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "52 Week Change",
              row1Value: "$weekChange52",
              row2Title: "Shares Outstanding:",
              row2Value: "$sharesOuts",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CompanyInfoRowWidget(
              row1Title: "Country:",
              row1Value: "$country",
              row2Title: "Sector:",
              row2Value: "$sector",
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.90 + 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                "About the company",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              // color: Color(0xFFEEEEEE),
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * 0.90 + 10,
            child: Text(
              "$longSummary",
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }
}
