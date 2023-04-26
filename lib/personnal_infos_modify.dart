// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PersonnalInfo extends StatefulWidget {
  String username = "";
  String password = "";
  String phone = "";
  String emergency = "";
  PersonnalInfo(
      {super.key,
      required this.username,
      required this.password,
      required this.phone,
      required this.emergency});

  @override
  State<PersonnalInfo> createState() => _PersonnalInfoState();
}

class _PersonnalInfoState extends State<PersonnalInfo> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("members");
  final controllerUsername = TextEditingController();
  final controllerPassword1 = TextEditingController();
  final controllerPassword2 = TextEditingController();
  final controllerPhone = TextEditingController();
  final controllerEmergency = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controllerUsername.text = widget.username;
    controllerPassword1.text = widget.password;
    controllerPhone.text = widget.phone;
    controllerEmergency.text = widget.emergency;

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
          title: const Text("Personnal Information"),
          centerTitle: true,
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50),
                TextFormField(
                  controller: controllerUsername,
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
                const SizedBox(height: 50),
                TextFormField(
                  controller: controllerPhone,
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
                      labelText: 'Enter your personnal phone number.',
                      labelStyle: TextStyle(
                          color: Colors.white, decorationColor: Colors.white)),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: controllerEmergency,
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
                      labelText: 'Enter an emergency phone number.',
                      labelStyle: TextStyle(
                          color: Colors.white, decorationColor: Colors.white)),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 50),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: controllerPassword1,
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
                                color: Colors.white,
                                decorationColor: Colors.white)),
                        cursorColor: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: controllerPassword2,
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
                            labelText: 'Password validation.',
                            labelStyle: TextStyle(
                                color: Colors.white,
                                decorationColor: Colors.white)),
                        cursorColor: Colors.white,
                      ),
                    )
                  ],
                ),

                //const SizedBox(height: 50),

                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 20.0),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.purple[800]),
                  child: const Text(
                    "Update",
                    style: TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (controllerPassword1.text == controllerPassword2.text) {
                      if (controllerUsername.text == widget.username &&
                          controllerPassword1.text == widget.password &&
                          controllerPhone.text == widget.phone &&
                          controllerEmergency.text == widget.emergency) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text(
                                  'No update needed. Please modify your information before trying to update it.')),
                        );
                      } else {
                        if (controllerUsername.text != widget.username) {
                          debugPrint(controllerUsername.text);
                          debugPrint(widget.username);
                          debugPrint("ahoy");
                          final team =
                              await ref.child("${widget.username}/team").get();
                          final status =
                              await ref.child("${widget.username}/role").get();
                          final bpm =
                              await ref.child("${widget.username}/bpm").get();
                          final latitude = await ref
                              .child("${widget.username}/latitude")
                              .get();
                          final longitude = await ref
                              .child("${widget.username}/longitude")
                              .get();
                          ref.child(widget.username).remove();
                          widget.username = controllerUsername.text;
                          await ref.set({
                            controllerUsername.text: {
                              "password": widget.password,
                              "role": int.parse(status.value.toString()),
                              "team": team.value.toString(),
                              "bpm": int.parse(bpm.value.toString()),
                              "latitude":
                                  double.parse(latitude.value.toString()),
                              "longitude":
                                  double.parse(longitude.value.toString()),
                            }
                          });
                        }
                        if (widget.password != controllerPassword1.text) {
                          debugPrint("ahok");
                          await ref.update({
                            '${controllerUsername.text}/password':
                                controllerPassword1.text
                          });
                        }
                        if (widget.phone != controllerPhone.text) {
                          await ref.update({
                            '${controllerUsername.text}/personnal_number':
                                controllerPhone.text
                          });
                        }
                        if (widget.emergency != controllerEmergency.text) {
                          await ref.update({
                            '${controllerUsername.text}/emergency_number':
                                controllerEmergency.text
                          });
                        }
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text(
                                  'You have succesfully changed your information. Click to go back to the main page.')),
                        ).then((value) async {
                          final team = await ref
                              .child("${controllerUsername.text}/team")
                              .get();
                          final status = await ref
                              .child("${controllerUsername.text}/role")
                              .get();
                          final bpm = await ref
                              .child("${controllerUsername.text}/bpm")
                              .get();

                          Navigator.pop(context, [
                            controllerUsername.text,
                            team.value.toString(),
                            bpm.value.toString(),
                            controllerEmergency.text,
                          ]);
                        });
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
