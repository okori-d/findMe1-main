import 'dart:async';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), openEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        //for full screen set heightFactor: 1.0,widthFactor: 1.0,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: AssetImage('assets/images/logo.jpeg'))),
      ),
    );
  }

  void openEvents() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }
}
