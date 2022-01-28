import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyInfoRowWidget extends StatelessWidget {
  final row1Title;
  final row1Value;
  final row2Title;
  final row2Value;
  final _customFontSizeTitle = 14.0;
  final _customFontSizeValue = 14.0;
  // final _containerColorCode = int.tryParse("0xFF" + "EEEEEE");
  final _containerColorCode = Colors.white;
  final _titleColor = Colors.grey[700];
  final _textWidth = 150.0;
  CompanyInfoRowWidget({
    Key? key,
    this.row1Title,
    this.row1Value,
    this.row2Title,
    this.row2Value,
  }) : super(key: key);
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _containerColorCode,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _textWidth,
              child: Text(
                row1Title,
                style: GoogleFonts.roboto(
                  fontSize: _customFontSizeTitle,
                  color: _titleColor,
                ),
              ),
            ),
            SizedBox(height: 3),
            Container(
              width: _textWidth,
              child: Text(
                row1Value,
                style: GoogleFonts.roboto(
                  fontSize: _customFontSizeValue,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _containerColorCode,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _textWidth,
              child: Text(
                row2Title,
                style: GoogleFonts.roboto(
                  fontSize: _customFontSizeTitle,
                  color: _titleColor,
                ),
              ),
            ),
            SizedBox(height: 3),
            Container(
              width: _textWidth,
              child: Text(
                row2Value,
                style: GoogleFonts.roboto(
                  fontSize: _customFontSizeValue,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
