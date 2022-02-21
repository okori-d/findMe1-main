import 'package:flutter/material.dart';
import 'package:flutter_application_1/HOME/placePicker/stf.dart';
import 'DashBoard.dart';
import 'Reccomendations.dart';
import 'Settings.dart';
import 'UserProfile/pages/profile_page.dart';
import 'package:alan_voice/alan_voice.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _HomeState() {
    /// Init Alan Button with project key from Alan Studio
    AlanVoice.addButton(
        "2dce9db4cc93264ded31a41c11f85eda2e956eca572e1d8b807a3e2338fdd0dc/stage");

    /// Handle commands from Alan Studio
    AlanVoice.onCommand.add((command) {
      debugPrint("got new command ${command.toString()}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashBoard(),
          Container(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      image: DecorationImage(
            image: AssetImage("assets/images/bg5.jfif"),
            fit: BoxFit.fill,
          )))),
          Container(
              padding: EdgeInsets.all(15),
              child: Text('Recommendations',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'assets\font\RobotoSlab-Regular.ttf',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ))),
          SizedBox(width: 15),
          Expanded(
            child: HomePagex(),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10)
          ]),
      child: ClipRRect(
          child: BottomNavigationBar(
              backgroundColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey.withOpacity(0.5),
              items: [
            BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(
                  Icons.home_max_rounded,
                  size: 30,
                )),
            BottomNavigationBarItem(
              label: 'Settings',
              icon: IconButton(
                icon: Icon(
                  Icons.settings_applications_rounded,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                },
                color: Colors.black,
              ),
            ),
          ])),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(children: [
        Container(
            height: 45,
            width: 45,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/avatar.png'))),
        SizedBox(width: 10),
        Text(
          'Hi, there....',
          style: TextStyle(
              color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ]),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          },
          color: Colors.black,
        )
      ],
    );
  }
}
