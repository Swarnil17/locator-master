import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location location = Location();
  final databaseReference = FirebaseDatabase.instance.ref();
  Map<String, double> currentLocation = new Map();
  late StreamSubscription<LocationData> locationSubcription;
  bool _permissionGiven = false;
  bool isInitiated = false;

  @override
  void initState() {
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    super.initState();
  }

  Future<void> initLocationDetail() async {
    PermissionStatus _permissionGranted;
    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        showErrorSnackbar("Please enable your location");
      } else {
        setState(() {
          _permissionGiven = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(219, 233, 246, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(40.0),
              child: Image.asset(
                'images/icon.png',
                height: MediaQuery.of(context).size.height / 2,
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Track it!',
                  style: TextStyle(
                      color: const Color.fromRGBO(19, 39, 88, 1),
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                )),
                if(!isInitiated)
                Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Share your Location',
                  style: TextStyle(
                      color: const Color.fromRGBO(19, 39, 88, 1),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                )),
          if (isInitiated)
            Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Text(
                  // "Longitude: ${currentLocation['longitude']} Latitude: ${currentLocation['latitude']}",
                  "Sharing location",
                  style: TextStyle(
                      color: const Color.fromRGBO(19, 39, 88, 1),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                )),
                // 
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: MaterialButton(
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color(0xFF8570FF),
              elevation: 0,
              minWidth: double.infinity,
              child:  Text(
                (isInitiated)? "Stop":
                "Share location",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: () async {
                if (isInitiated == false) {
              _subscribeLocation();
  
            }else{
            close();
            }
            setState(() {
                isInitiated = !isInitiated;
              });
              },
            ),
          )
        ],
      ),
    );
  }

  void UpdateDatabase() {
    databaseReference.child("location").set({
      'latitude': currentLocation['latitude'],
      'longitude': currentLocation['longitude'],
    });
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 10.0,
      margin: EdgeInsets.all(16.0),
      duration: Duration(seconds: 5),
      icon: Icon(Icons.error),
    );
  }

  void _subscribeLocation() {
    locationSubcription = location.onLocationChanged.listen((value) {
      setState(() {
        currentLocation['latitude'] = value.latitude!;
        currentLocation['longitude'] = value.longitude!;
      });
    UpdateDatabase();
    });
  }

  void close(){
    locationSubcription.cancel();
  }

  @override
  void dispose() {
    locationSubcription.cancel();
    super.dispose();
  }
}
