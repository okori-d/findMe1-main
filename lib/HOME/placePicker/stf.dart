

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HOME/Constants/Secrets.dart';
import 'package:flutter_application_1/HOME/Weather/theme/theme_data.dart';
import 'package:flutter_geofence/geofence.dart';  
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:math' show cos, sqrt, asin;

void main() => runApp(MapViewPage());

class MapViewPage extends StatelessWidget {
  // Light Theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.white,
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Background color of the FloatingCard
    cardColor: Colors.grey,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Picker',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: MapView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  static const kInitialPosition = LatLng(0.334873, 32.567497);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(0.333488, 32.568202),
    zoom: 15,
  );
  late GoogleMapController mapController;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  /*@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    polylinePoints = PolylinePoints();
    
  }*/

  

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static final Marker _DICTSofficesMarker = Marker(
    markerId: MarkerId('_place1'),
    infoWindow: InfoWindow(
      title: 'DICTS Offices',
      snippet: 'Student portal and muele issues',
    ),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(0.331331, 32.570553),
  );

 /* static final Marker _maryStuartGymMarker = Marker(
    markerId: MarkerId('_place1'),
    infoWindow: InfoWindow(
      title: 'Gym',
      snippet: 'Equipped with state of the art equipment',
    ),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(0.330588, 32.567492),
  );*/

  static final Marker _poolCourtMarker = Marker(
    markerId: MarkerId('_place1'),
    infoWindow: InfoWindow(
      title: 'Pool Basketball court',
      snippet: 'Available for basketball games',
    ),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(0.334608, 32.569307),
  );
  static final Marker _swimmingPoolMarker = Marker(
    markerId: MarkerId('_place1'),
    infoWindow: InfoWindow(
      title: 'Swimming pool',
      snippet: 'Free for Makerere students',
    ),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(0.335027, 32.569269),
  );

  static final Marker _SenateBuildingMarker = Marker(
    markerId: MarkerId('_SenateBuilding'),
    infoWindow: InfoWindow(
      title: 'Senate Building',
      snippet: 'IDs and Admission issues',
    ),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(0.333192, 32.569493),
  );


  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  
  
    @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    //polylinePoints = PolylinePoints();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 20,
              title: Text('FindMe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle:FontStyle.normal,
                fontSize: 25,
                color: Colors.white,
              ),
              ),
              centerTitle: false,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                  top: Radius.circular(16),
                  ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade900, Colors.cyanAccent, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ),
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[

            
            // Map View
            GoogleMap(
              markers: {
                _DICTSofficesMarker,
                _SenateBuildingMarker,
                //_maryStuartGymMarker,
                Marker(
                  markerId: const MarkerId('_place1'),
                  onTap: () {

                    //"Hey" to test interaction with the marker.
                      //print('Hey');
                    
                    var geolocation = const Geolocation(latitude:0.330588,longitude: 32.567492, id: 'maryStuart', radius:12);
                    Geofence.addGeolocation(geolocation, GeolocationEvent.entry).then((value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gym Added to geofence!"),),),);
                  },
                  infoWindow: const InfoWindow(
                    title: 'Gym',
                    snippet: 'Equipped with state of the art equipment',
      
                  ),
                  icon: BitmapDescriptor.defaultMarker,
                  position: const LatLng(0.330588, 32.567492),
    
                ),
                _swimmingPoolMarker,
                _poolCourtMarker,
                //Set<Marker>.from(markers)
              },
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: _polylines,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                setPolylines();
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blueAccent.shade200.withOpacity(0.75), // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blueAccent.shade200.withOpacity(0.75), // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.blueAccent.shade200.withOpacity(0.75), // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCX7vI-UAjpQsj4o2cjlm4VHKlwntoFXRs',
      PointLatLng(_currentPosition.latitude, _currentPosition.longitude),//origin position
      const PointLatLng(0.330588, 32.567492),//destination position.
      );
      
      if (result.status == 'OK') {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(
            Polyline(
              width: 5,
              polylineId: const PolylineId('polyline'),
              color: Colors.blueAccent.shade200.withOpacity(0.8),
              points: polylineCoordinates,
            )
          );
        });
      }
  }
}
