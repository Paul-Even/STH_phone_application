// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RemoveMember extends StatefulWidget {
  String team = "";
  String password = "";
  RemoveMember({super.key, required this.team, required this.password});

  @override
  State<RemoveMember> createState() => _RemoveMemberState();
}

class _RemoveMemberState extends State<RemoveMember> {
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("members"); //Gets the database "members" node's adress
  final controller1 =
      TextEditingController(); //Creates a text controller for each of the three text zones
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
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
            //Button to go back to the main page
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text("Add a member"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              TextFormField(
                //Text field to enter the username of the wanted member
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
                    labelText: 'Enter the username.',
                    labelStyle: TextStyle(
                        color: Colors.white, decorationColor: Colors.white)),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 100),
              TextFormField(
                //Text field to get the admin's password
                controller: controller2,
                style: const TextStyle(color: Colors.white),
                obscureText: true, //Hides the given text
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
              const SizedBox(height: 100),
              TextFormField(
                //Text field to validate the given password
                controller: controller3,
                style: const TextStyle(color: Colors.white),
                obscureText: true, //Hides the given text
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
                    labelText: 'Confirm your password.',
                    labelStyle: TextStyle(
                        color: Colors.white, decorationColor: Colors.white)),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                //Button to validate the deletion
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20.0),
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.purple[800]),
                child: const Text(
                  "Remove",
                  style: TextStyle(fontSize: 35),
                ),
                onPressed: () async {
                  if (controller2.text == controller3.text &&
                      controller2.text == widget.password) {
                    //Checks if both given password are the same as the user's one
                    List<String> names = [];
                    DataSnapshot users = await ref.get();
                    bool deleted = false;

                    users.children.forEach((key) async {
                      var team = await ref
                          .child(key.key.toString())
                          .child("team")
                          .get();
                      if (team.value.toString() == widget.team) {
                        names.add(key.key.toString());
                      }
                      if (names.contains(controller1.text) == true) {
                        //Checks if the given username exists
                        ref.child(controller1.text).remove();
                        deleted = true; //Deletes the user
                        showDialog(
                          //Sends back to the main page
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(
                                  'You have succesfully removed ${controller1.text}. Click to go back to the main page.')),
                        ).then((value) async {
                          Navigator.pop(context);
                        });
                      }
                    });
                    if (deleted == false) {
                      //Popup message if the user has not been found
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text(
                                'This user has not be found. Please verify the given name.')),
                      );
                    }
                  } else {
                    //Popup if one of the password is wrong
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                          title: Text('Please verify your password.')),
                    );
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
