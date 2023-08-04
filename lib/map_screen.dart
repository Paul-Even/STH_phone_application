// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationScreen extends StatefulWidget {
  double latitude = 0; //Recovers the member's latitude and longitude
  double longitude = 0;
  String member;
  LocationScreen(
      {super.key,
      required this.member,
      required this.latitude,
      required this.longitude});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("members");
  double lat = 0;
  double long = 0;
  Set<Marker> markers = {}; //Set the list of markers to display on the map
  late Marker marker = Marker(
      //Creates a marker to see the member's position
      markerId: const MarkerId("Position"),
      position: LatLng(lat, long));
  late CameraPosition initialPosition = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14); //Initialize the initial position of the camera

  late GoogleMapController _controller;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  void initState() {
    debugPrint("bite");
    lat = widget.latitude;
    print("1");
    long = widget.longitude;
    print("1");
    _listenLatitude();
    print("1");
    _listenLongitude();
    print("1");
    //setState(() {});

    super.initState();
    print("1");
  }

  void _listenLatitude() {
    ref.child(widget.member).child("latitude").onValue.listen((event) async {
      double latitude = double.parse(event.snapshot.value.toString());

      setState(() {
        debugPrint("change lat");
        lat = latitude;
        initialPosition = CameraPosition(target: LatLng(lat, long), zoom: 11);
        _controller
            .animateCamera(CameraUpdate.newCameraPosition(initialPosition));
        marker = Marker(
            //Creates a marker to see the member's position
            markerId: const MarkerId("Position"),
            position: LatLng(lat, long));
      });
    });
  }

  void _listenLongitude() {
    ref.child(widget.member).child("longitude").onValue.listen((event) async {
      double longitude = double.parse(event.snapshot.value.toString());
      debugPrint("change long");

      setState(() {
        long = longitude;
        initialPosition = CameraPosition(target: LatLng(lat, long), zoom: 11);
        _controller
            .animateCamera(CameraUpdate.newCameraPosition(initialPosition));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    marker = Marker(
        //Creates a marker to see the member's position
        markerId: const MarkerId("Position"),
        position: LatLng(lat, long)); //Sets the position of the marker

    markers = {}; //Set the list of markers to display on the map

    markers.add(marker); //Add the created marker to the list
    setState(() {});
    print("length ${markers.length}");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            //Button to go back to the main screen
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          title: const Text("Location screen"),
          centerTitle: true,
          backgroundColor: Colors.purple[800],
        ),
        body: GoogleMap(
          //Creates a Google Map instance as the body of the screen
          initialCameraPosition: initialPosition,
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          markers: markers,
        ),
      ),
    );
  }
}
