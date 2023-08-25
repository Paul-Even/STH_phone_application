// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; //Package used to get the user's device token when he gets connected
import 'main.dart';

class ConnectionMenu extends StatefulWidget {
  const ConnectionMenu({super.key});

  @override
  State<ConnectionMenu> createState() => _ConnectionMenuState();
}

class _ConnectionMenuState extends State<ConnectionMenu> {
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("members"); //Gets the database "members" node's adress
  DatabaseReference ref2 = FirebaseDatabase.instance
      .ref("shirts"); //Gets the database "members" node's adress
  String username = "";
  final controller1 =
      TextEditingController(); //Creates a text controller for each of the two text zones
  final controller2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset:
            false, //Avoid bugs caused by the user's keyboard
        backgroundColor: Colors.purple[900],
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          /*leading: IconButton(
            //Button to go back to the main screen
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),*/
          title: const Text("Connection menu"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 100),
              TextFormField(
                //Text field to enter the username
                controller: controller1,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Enter your name.',
                    labelStyle: TextStyle(
                        color: Colors.white, decorationColor: Colors.white)),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 100),
              TextFormField(
                //Text field to enter the password
                controller: controller2,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Enter your password.',
                    labelStyle: TextStyle(
                        color: Colors.white, decorationColor: Colors.white)),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 200),
              ElevatedButton(
                //Button to validate the connection
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20.0),
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.purple[800]),
                child: const Text(
                  "Connect",
                  style: TextStyle(fontSize: 35),
                ),
                onPressed: () async {
                  debugPrint(controller1.text);
                  try {
                    await ref2.child("HeRaShirt1").set({
                      //Creates a new member in the database

                      "team": "Smart Textiles Hub",
                      "bpm": 0,
                      "latitude": 0,
                      "longitude": 0,
                    });
                    if (controller1.text != "") {
                      //Checks if there is a username
                      final username = await ref
                          .child(controller1.text)
                          .get(); //Gets the username from the database
                      if (username.exists) {
                        //Checks if the username exists
                        final password = await ref
                            .child("${controller1.text}/password")
                            .get(); //Gets the password from the database
                        if (password.value.toString() == controller2.text) {
                          //Checks if the retrieved password corresponds
                          await FirebaseMessaging
                              .instance //Gets the device token
                              .getToken()
                              .then((token) async {
                            ref.child(controller1.text).update({
                              //Updates it
                              "token":
                                  await FirebaseMessaging.instance.getToken()
                            });
                          });
                          showDialog(
                            //Sends the user back to the main page after a popup validation message
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text(
                                    'You have succesfully connected to your account. Click to go back to the main page.')),
                          ).then((value) async {
                            final team = await ref
                                .child("${controller1.text}/team")
                                .get();
                            final status = await ref
                                .child("${controller1.text}/role")
                                .get();
                            final bpm = await ref
                                .child("${controller1.text}/bpm")
                                .get();
                            final emergency = await ref
                                .child("${controller1.text}/emergency_number")
                                .get();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainPage(
                                          username: controller1.text,
                                          teamname: team.value.toString(),
                                          role: int.parse(
                                              status.value.toString()),
                                          bpm: bpm.value.toString(),
                                          emergency_number:
                                              emergency.value.toString(),
                                        )));
                            /*Navigator.pop(context, [
                              //Gives useful information back to the main page
                              controller1.text,
                              team.value.toString(),
                              status.value.toString(),
                              bpm.value.toString(),
                              emergency.value.toString()
                            ]);*/
                          });
                        } else {
                          //If the passwords doesn't correspond, shows a popup message
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text(
                                    'You might have entered a wrong name or password. Please try again.')),
                          );
                        }
                      } else {
                        //If the username doesn't exist, shows a popup message
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text(
                                  'You might have entered a wrong name or password. Please try again.')),
                        );
                      }
                    } else {
                      //If no username was given, shows a popup message
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text(
                                'You might have entered a wrong name or password. Please try again.')),
                      );
                    }
                  } catch (e) {
                    debugPrint("Build error");
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
