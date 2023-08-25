// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; //Package used to gzt the user's device token when he gets connected
import 'main.dart';

class ShirtMenu extends StatefulWidget {
  String team = "";
  ShirtMenu({super.key, required this.team});

  @override
  State<ShirtMenu> createState() => _ShirtMenuState();
}

class _ShirtMenuState extends State<ShirtMenu> {
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("shirts"); //Gets the database "members" node's adress
  String team = "";
  final controller1 =
      TextEditingController(); //Creates a text controller for each of the two text zones

  void initState() {
    team = widget.team;
    super.initState();
  }

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
          leading: IconButton(
            //Button to go back to the main screen
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          title: const Text("Shirt selection"),
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
                    labelText: 'Enter your shirt\'s name.',
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
                    if (controller1.text != "") {
                      //Checks if there is a username
                      debugPrint("c1 non nul");
                      final shirts = await ref
                          .get(); //Gets the shirt names from the database
                      debugPrint("ahahaha + ${shirts.children}");
                      for (DataSnapshot key in shirts.children) {
                        print("for");
                        if (key.key.toString() == controller1.text) {
                          //Checks if the username exists
                          print(key.key.toString());
                          final teamname = await ref
                              .child("${controller1.text}/team")
                              .get(); //Gets the password from the database

                          //Checks if the retrieved password corresponds
                          if (teamname.value.toString() == team) {
                            showDialog(
                              //Sends the user back to the main page after a popup validation message
                              context: context,
                              builder: (context) => const AlertDialog(
                                  title: Text(
                                      'You have succesfully connected to your shirt. Click to go back to the main page.')),
                            ).then((value) async {
                              Navigator.pop(context, [
                                //Gives useful information back to the main page
                                controller1.text
                              ]);
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                  title: Text(
                                      'You might have entered a wrong name. Please try again.')),
                            );
                          }
                        }
                      }
                    } else {
                      //If no username was given, shows a popup message
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text(
                                'You might have entered a wrong name. Please try again.')),
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
