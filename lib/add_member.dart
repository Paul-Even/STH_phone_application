// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class addMember extends StatefulWidget {
  String team = "";
  addMember({super.key, required this.team});

  @override
  State<addMember> createState() => _addMemberState();
}

class _addMemberState extends State<addMember> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("members");
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  bool isAdmin = false;
  int role = 2;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.purple[900],
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text("Add a member"),
          centerTitle: true,
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50),
                TextFormField(
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
                      labelText: 'Enter the password.',
                      labelStyle: TextStyle(
                          color: Colors.white, decorationColor: Colors.white)),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 100),
                TextFormField(
                  controller: controller3,
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
                      labelText: 'Confirm the password.',
                      labelStyle: TextStyle(
                          color: Colors.white, decorationColor: Colors.white)),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 50),
                Row(
                  children: <Widget>[
                    const Text(
                      "Administrator : ",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    SizedBox(width: 30),
                    Transform.scale(
                      scale: 2,
                      child: Switch.adaptive(
                          activeColor: Colors.white,
                          value: isAdmin,
                          onChanged: (value) {
                            setState(() {
                              isAdmin = value;
                              if (value == false) {
                                role = 2;
                                value = true;
                              } else if (value == true) {
                                role = 1;
                              }
                            });
                          }),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 20.0),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.purple[800]),
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (controller2.text == controller3.text) {
                      List<String> names = [];
                      DataSnapshot users = await ref.get();
                      users.children.forEach((key) {
                        names.add(key.key.toString());
                      });
                      if (names.contains(controller1.text) == false) {
                        await ref.child(controller1.text).set({
                          "password": controller2.text,
                          "role": role,
                          "team": widget.team,
                          "bpm": 0,
                          "latitude": 0,
                          "longitude": 0
                        });
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(
                                  'You have succesfully registered ${controller1.text}. Click to go back to the main page.')),
                        ).then((value) async {
                          Navigator.pop(context);
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text(
                                  'This name already exists. Please enter another one')),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text('Please verify the password.')),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
