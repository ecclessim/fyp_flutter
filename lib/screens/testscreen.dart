import 'package:flutter/material.dart';
import 'package:fyp_flutter/screens/home_screen.dart';
import 'package:fyp_flutter/screens/portfolio_optimisation_screen.dart';
import 'package:fyp_flutter/screens/search_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _pageOptions = [
    HomeScreen(),
    SearchScreen(),
    PortfolioOptimisationScreen(),
  ];
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pageOptions[selectedPage],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 3,
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined, size: 30), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search, size: 30), label: 'Search Stocks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.spa_rounded, size: 30),
                    label: 'Information'),
              ],
              selectedItemColor: Colors.blue,
              elevation: 5.0,
              unselectedItemColor: Colors.black,
              currentIndex: selectedPage,
              onTap: (index) {
                setState(() {
                  selectedPage = index;
                });
              },
            ),
          ),
        ));
  }
}
