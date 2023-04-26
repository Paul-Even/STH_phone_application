import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  double latitude = 0;
  double longitude = 0;
  LocationScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late final Marker marker = Marker(
      markerId: MarkerId("Position"),
      position: LatLng(widget.latitude, widget.longitude));
  static Set<Marker> markers = {};

  late CameraPosition initalPostition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude), zoom: 14);

  @override
  Widget build(BuildContext context) {
    markers.add(marker);
    setState(() {});
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
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
