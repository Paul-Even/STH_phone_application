// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ConnectionMenu extends StatefulWidget {
  const ConnectionMenu({super.key});

  @override
  State<ConnectionMenu> createState() => _ConnectionMenuState();
}

class _ConnectionMenuState extends State<ConnectionMenu> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("members");
  String username = "Paul Even";
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
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
          title: const Text("Connection menu"),
          centerTitle: true,
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 100),
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
                      labelText: 'Enter your name.',
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
                const SizedBox(height: 200),
                ElevatedButton(
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
                        final username =
                            await ref.child(controller1.text).get();
                        if (username.exists) {
                          debugPrint(username.value.toString());
                          final password = await ref
                              .child("${controller1.text}/password")
                              .get();
                          debugPrint(password.value.toString());
                          if (password.value.toString() == controller2.text) {
                            await FirebaseMessaging.instance
                                .getToken()
                                .then((token) async {
                              ref.child(controller1.text).update({
                                "token":
                                    await FirebaseMessaging.instance.getToken()
                              });
                            });
                            showDialog(
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

                              Navigator.pop(context, [
                                controller1.text,
                                team.value.toString(),
                                status.value.toString(),
                                bpm.value.toString(),
                                emergency.value.toString()
                              ]);
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                  title: Text(
                                      'You might have entered a wrong name or password. Please try again.')),
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                title: Text(
                                    'You might have entered a wrong name or password. Please try again.')),
                          );
                        }
                      } else {
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
      ),
    );
  }
}
