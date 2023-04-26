// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  double latitude = 0; //Recovers the member's latitude and longitude
  double longitude = 0;
  LocationScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer(); //Initialize the map controller

  late final Marker marker = Marker(
      //Creates a marker to see the member's position
      markerId: const MarkerId("Position"),
      position: LatLng(
          widget.latitude, widget.longitude)); //Sets the position of the marker
  static Set<Marker> markers =
      {}; //Set the list of markers to display on the map

  late CameraPosition initalPostition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 14); //Initialize the initial position of the camera

  @override
  Widget build(BuildContext context) {
    markers.add(marker); //Add the created marker to the list
    setState(() {});
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            //Button to go back to the main screen
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Location screen"),
          centerTitle: true,
          backgroundColor: Colors.purple[900],
        ),
        body: GoogleMap(
          //Creates a Google Map instance as the body of the screen
          initialCameraPosition: initalPostition,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markers,
        ),
      ),
    );
  }
}
