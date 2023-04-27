// ignore_for_file: must_be_immutable, camel_case_types, avoid_unnecessary_containers, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'map_screen.dart';

class teamInfos extends StatefulWidget {
  const teamInfos({super.key});

  @override
  State<teamInfos> createState() => _teamInfosState();
}

class _teamInfosState extends State<teamInfos> {
  @override
  void initState() {
    onChanged();
    super.initState();
  }

  void onChanged() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("members");
    ref.onValue.listen((event) async {
      setState(() {});
    });
  }

  ListView _buildListViewOfEvents() {
    //Building the list's view with the given containers
    List<Container> containers = <Container>[];
    containers.add(
      Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(),
            ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Column(),
        ...containers,
      ],
    );
  }

  Widget _buildView() {
    return _buildListViewOfEvents();
  }

  Future<List<Widget>> getContainers(String teamname) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("members");
    List<String> members = [];
    String roles = "";
    String bpm = "";
    String phone = "";
    double latitude = 0;
    double longitude = 0;
    List<Container> containers = [];
    DataSnapshot users = await ref.get();

    for (DataSnapshot key in users.children) {
      var team;
      await ref
          .child("/${key.key.toString()}")
          .child("/team")
          .get()
          .then((value) => team = value);
      if (team.value.toString() == teamname &&
          members.contains(key.key.toString()) == false) {
        //Getting and saving the member's role
        final dataRole =
            await ref.child("/${key.key.toString()}").child("/role").get();
        if (int.parse(dataRole.value.toString()) == 1) {
          roles = "Administrator";
        } else {
          roles = "Member";
        }

        //Getting and saving the member's bpm
        final dataBPM =
            await ref.child("/${key.key.toString()}").child("/bpm").get();
        bpm = dataBPM.value.toString();

        //Saving the member's name
        members.add(key.key.toString());
        print("latitude : $latitude");
        print("longitude : $longitude");
        containers.add(
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Name : ${key.key.toString()}", //Displays the member's name
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Role : $roles", //Displays the member's role
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                "BPM : $bpm", //Displays the member's BPM
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                    //Displaying a button to call the member
                                    iconSize: 50,
                                    color: Colors.white,
                                    onPressed: () async {
                                      //Getting and saving the member's personnal phone
                                      final dataPhone = await ref
                                          .child("/${key.key.toString()}")
                                          .child("/personnal_phone")
                                          .get();
                                      phone = dataPhone.value.toString();
                                      await FlutterPhoneDirectCaller.callNumber(
                                          phone);
                                    },
                                    icon: const Icon(Icons.phone)),
                                IconButton(
                                    //Displaying a button to see the member's location
                                    iconSize: 50,
                                    color: Colors.white,
                                    onPressed: () async {
                                      final dataLat = await ref
                                          .child("/${key.key.toString()}")
                                          .child("/latitude")
                                          .get();
                                      latitude = double.parse(
                                          dataLat.value.toString());

                                      //Getting and saving the member's longitude
                                      final dataLon = await ref
                                          .child("/${key.key.toString()}")
                                          .child("/longitude")
                                          .get();
                                      longitude = double.parse(
                                          dataLon.value.toString());
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LocationScreen(
                                                  latitude: latitude,
                                                  longitude: longitude,
                                                )),
                                      );
                                    },
                                    icon: const Icon(Icons.location_pin)),
                              ],
                            ),
                          )),
                        ],
                      ),
                      const Divider(
                        height: 30,
                        thickness: 5,
                        indent: 0,
                        endIndent: 0,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (containers.isEmpty) {
      print("containers vides");
    }
    return <Widget>[
      //Put all the containers in one column
      Column(
        children: const <Widget>[SizedBox(height: 10)],
      ),
      ...containers,
    ];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          title: Text(
            'Team Members',
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.purple[900],
        body: Column(
          children: <Widget>[
            FutureBuilder(
                future: getContainers("Smart Textiles Hub"),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Widget>> snapshot) {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    print(snapshot.data);
                    return Column(
                      children: snapshot.data!,
                    );
                  } else {
                    return Column();
                  }
                })
          ],
        ),
      );
}
