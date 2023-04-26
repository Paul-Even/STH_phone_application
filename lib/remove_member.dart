// ignore_for_file: use_build_context_synchronously

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
                      labelText: 'Enter your password.',
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
                      labelText: 'Confirm your password.',
                      labelStyle: TextStyle(
                          color: Colors.white, decorationColor: Colors.white)),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 100),
                ElevatedButton(
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
                      List<String> names = [];
                      DataSnapshot users = await ref.get();
                      users.children.forEach((key) {
                        names.add(key.key.toString());
                      });
                      if (names.contains(controller1.text) == true) {
                        ref.child(controller1.text).remove();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(
                                  'You have succesfully removed ${controller1.text}. Click to go back to the main page.')),
                        ).then((value) async {
                          Navigator.pop(context);
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text(
                                  'This user has not be found. Please verify the given name.')),
                        );
                      }
                    } else {
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
      ),
    );
  }
}
