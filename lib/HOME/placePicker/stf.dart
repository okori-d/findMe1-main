

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HOME/Constants/Secrets.dart';
import 'package:flutter_application_1/HOME/Weather/theme/theme_data.dart';
import 'package:flutter_application_1/HOME/placePicker/PlaceModal.dart';
import 'package:flutter_geofence/geofence.dart';  
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;
import 'Search.dart';

import 'package:overlay_support/overlay_support.dart';

void main(){
  
}

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
      home: const MapView(),
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
  CameraPosition _initialLocation = const CameraPosition(
    target: LatLng(0.333488, 32.568202),
    zoom: 15,
  );
  late GoogleMapController mapController;

  late Position _currentPosition;
  late Position _destinationPosition;
  String _currentAddress = '';
  Iterable<Marker> _markers = [];
  late Marker _destination;
  int placed = PlaceDetails.places.length;
  
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;


  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  MapType _currentMapType = MapType.normal;  
  
    @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    polylinePoints = PolylinePoints();
    

    //***Generating the iterables to mapped as markers */
    Iterable<Marker> placeMarker = Iterable.generate(placed,(index){
    return  Marker(
    markerId: MarkerId(PlaceDetails.places[index]['id']),
    infoWindow: InfoWindow(
      title: PlaceDetails.places[index]['title'],
      snippet: PlaceDetails.places[index]['snippet'],
    ),
    icon: PlaceDetails.places[index]['icon'],
    position: PlaceDetails.places[index]['position'],
      onTap: () {
                var geolocation =  Geolocation(latitude:PlaceDetails.places[index]['position'].latitude,longitude: PlaceDetails.places[index]['position'].longitude, id: PlaceDetails.places[index]['id'], radius:12);
                    Geofence.addGeolocation(geolocation, GeolocationEvent.entry).then((value) => showNotification("${PlaceDetails.places[index]['title']} Added to geofence!"));
                  },
  );
  });
  
        /**allow Geofence to use your phone location */
    Geofence.requestPermissions();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      showNotification("You are near: ${entry.id}. Check map to view it.");
    });

    // Geofence.startListeningForLocationChanges();
    Geofence.backgroundLocationUpdated.stream.listen((event) { 
      showNotification("You moved ${event.latitude} and ${event.longitude}");
    });

setState(() {
  _markers = placeMarker;
});
  }

// @override
//   void dispose(){
//     super.dispose();
//     Geofence.stopListeningForLocationChanges();
//   }

  showMessage(String msg){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg),),);
  }

  showNotification(String msg){
    showOverlayNotification((context){
        return Padding(
          padding: const EdgeInsets.only(top:58.0),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Card(
              child: ListTile(
                title: Text(msg),
                leading: CircleAvatar(child: Icon(Icons.notifications),),
                trailing: IconButton(onPressed: (){
                  setState((){
                      
                  });
                }, icon: Icon(Icons.close)),
                ),
              ),
          ),
        );
    });
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          child: const Icon(Icons.map),
          backgroundColor: Colors.blueAccent.shade200.withOpacity(0.75),
          foregroundColor: Colors.white,
          onPressed: () {
            _toggleMapType();
          },
        ),
        appBar: AppBar(
          leadingWidth: 20,
              title: const Text('FindMe',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle:FontStyle.normal,
                fontSize: 25,
                color: Colors.white,
              ),
              ),
              centerTitle: false,
              elevation: 6,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(16),
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
              actions: [
                IconButton(onPressed: () {
                  showSearch(
                    context: context, 
                    delegate: customSearchDelegate(),
                    );
                },
                 icon: Icon(Icons.search))
              ],
              ),
              drawer: Drawer(),
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[ 
            // Map View
            GoogleMap(
              markers: Set.from(_markers),
              onLongPress: _addMarker,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: _polylines,
              mapType: _currentMapType,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // setPolylines();
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
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blueAccent.shade200.withOpacity(0.75), // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: const SizedBox(
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
                      elevation: 4,
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
                                tilt: 60,
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
  void setPolylines(LatLng pos) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCX7vI-UAjpQsj4o2cjlm4VHKlwntoFXRs',
      PointLatLng(_currentPosition.latitude, _currentPosition.longitude),//origin position
      PointLatLng(pos.latitude, pos.longitude),//destination position.
      );
      
      if (result.status == 'OK') {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(
            Polyline(
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
              width: 5,
              polylineId: const PolylineId('polyline'),
              color: Colors.blueAccent.shade200.withOpacity(0.8),
              points: polylineCoordinates,
              geodesic: true,
            )
          );
        });
      }
  }
  void _addMarker(LatLng pos) {
    
    
    setState(() {
    //   _destination = Marker(
    //     markerId: MarkerId('destination'),
    //     infoWindow: InfoWindow(title: 'Go here'),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    //     position: pos,
    //   );
    //  var p = _markers.toList();
    //  p.add(_destination);

      var dat = {'id':'destination','title':'Go here','snippet':'','icon': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),'position':LatLng(pos.latitude, pos.longitude,)};

      PlaceDetails.places.add(dat);
      showNotification("You have added your destination");

      setPolylines(LatLng(pos.latitude, pos.longitude));
    });
    //PlaceDetails.places.remove(dat);
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal) ? MapType.satellite: MapType.normal;
    });
  }
  @override
  void dispose() {

    super.dispose();
    
    Geofence.removeAllGeolocations();
    Geofence.stopListeningForLocationChanges();
  }
}
