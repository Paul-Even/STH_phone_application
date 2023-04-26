// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sth_app/map_screen.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'connection_menu.dart';
import 'info_team.dart';
import 'personnal_infos_modify.dart';
import 'add_member.dart';
import 'remove_member.dart';
import 'notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          //primarySwatch: Colors.blue,
          ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? mtoken = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("My token is $mtoken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("UserTokens")
        .doc("User1")
        .set({'token': token});
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings(('@mipmap/ic_launcher'));
    var initializationsSettings =
        InitializationSettings(android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notif) async {
      try {
        if (notif.payload != null && notif.payload!.isNotEmpty) {
        } else {}
      } catch (e) {}
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("........onMessage...........");
      print(
          "onMessage: ${message.notification!.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: false,
      );
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['title']);
    });
  }

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("members");
  DatabaseReference ref2 = FirebaseDatabase.instance.ref("teams");
  String username = "Not connected";
  String teamname = "";
  String emergency_number = "";
  bool connected = false;
  int status = 2;
  List<String> members = [];
  @override
  void initState() {
    super.initState();
    _listenBPM();
    requestPermission();
    getToken();
    initInfo();
  }

  void _listenBPM() {
    if (connected == true) {
      ref.child(username).child("bpm").onValue.listen((event) async {
        int bpm = int.parse(event.snapshot.value.toString());
        if (bpm < 50 || bpm > 160) {
          final usernames =
              await ref.get(); //Here getting the list of members' names
          print(usernames.children.toList().toString());
          usernames.children.forEach((key) {});
          String token = "";
          print(token);
          List<String> admins = await getAdmins(usernames);
          for (String admin in admins) {
            DataSnapshot snapshot = await ref.child(admin).child("token").get();
            token = snapshot.value.toString();
            sendPushMessage(token, "$username has an abnormal heartrate.",
                "Emergency alert!");
            print("Alerte envoyée par $username");
          }
        }
      });
    }
  }

  //@override
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 1;

  int bpm = 0;

  DatabaseReference database = FirebaseDatabase.instance.ref("teams/");

  Future<List<String>> getMembers(DataSnapshot username) async {
    username.children.forEach((key) async {
      var team;
      await ref
          .child("/${key.key.toString()}")
          .child("/team")
          .get()
          .then((value) => team = value);
      //Future.delayed(const Duration(milliseconds: 100));
      if (team.value.toString() == teamname &&
          members.contains(key.key.toString()) == false) {
        setState(() {
          members.add(key.key.toString());
        });
      }
    });
    members.sort(
      (a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()),
    );
    return members;
  }

  Future<List<String>> getAdmins(DataSnapshot username) async {
    username.children.forEach((key) async {
      var team;
      await ref
          .child("/${key.key.toString()}")
          .child("/team")
          .get()
          .then((value) => team = value);
      //Future.delayed(const Duration(milliseconds: 100));
      if (team.value.toString() == teamname &&
          members.contains(key.key.toString()) == false) {
        final dataRole = await ref.child(key.key.toString() + "/role").get();
        String role = "";
        if (dataRole.value.toString() == "1") {
          setState(() {
            members.add(key.key.toString());
          });
        }
      }
    });
    return members;
  }

  Future<String> getRole(DatabaseReference ref, String path) async {
    final dataRole = await ref.child(path).get();
    String role = "";
    if (int.parse(dataRole.value.toString()) == 1) {
      role = "Administrator";
    } else {
      role = "Member";
    }
    return role;
  }

  Future<int> getBPM(DatabaseReference ref, String path) async {
    final dataBPM = await ref.child(path).get();
    return int.parse(dataBPM.value.toString());
  }

  Future<double> getLatitude(DatabaseReference ref, String path) async {
    final dataLat = await ref.child(path).get();
    return double.parse(dataLat.value.toString());
  }

  Future<double> getLongitude(DatabaseReference ref, String path) async {
    final dataLon = await ref.child(path).get();
    return double.parse(dataLon.value.toString());
  }

  Future<String> getPhone(DatabaseReference ref, String path) async {
    final dataPhone = await ref.child(path).get();
    return dataPhone.value.toString();
  }

  Future<List<Container>> getContainers(
      List<Container> containers,
      String name,
      String role,
      int bpm,
      String phone,
      double latitude,
      double longitude) async {
    containers.add(
      Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Name : $name",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Role : ${role.toString()}",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            "BPM : ${bpm.toString()}",
                            style: TextStyle(fontSize: 20, color: Colors.white),
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
                                iconSize: 50,
                                color: Colors.white,
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      phone);
                                },
                                icon: const Icon(Icons.phone)),
                            IconButton(
                                iconSize: 50,
                                color: Colors.white,
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LocationScreen(
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
    return containers;
  }

  Future<List<Widget>> buildListViewOfEvents() async {
    //Building the list's view

    final username = await ref.get(); //Here getting the list of members' names
    List<Container> containers = <Container>[];

    members = await getMembers(username);

    for (int i = 0; i < members.length; i++) {
      String role = await getRole(ref, "${members[i]}/role");
      print("Members length " + members.length.toString());

      int bpm = await getBPM(ref, "${members[i]}/bpm");

      String phone = await getPhone(ref, "${members[i]}/personnal_number");
      //Future.delayed(const Duration(milliseconds: 100));

      double latitude = await getLatitude(ref, "${members[i]}/latitude");

      double longitude = await getLatitude(ref, "${members[i]}/longitude");
      containers = await getContainers(
          containers, members[i], role, bpm, phone, latitude, longitude);
    }

    return <Widget>[
      Column(),
      ...containers,
    ];
  }

  void _onItemTapped(int index) async {
    try {
      if (index == 0) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnectionMenu()),
        );
        if (result != null) {
          username = result[0];
          teamname = result[1];
          status = int.parse(result[2]);
          bpm = int.parse(result[3]);
          emergency_number = result[4];
          connected = true;
        }
      }
      if (index == 1) {
        /*await ref.child("Pelle").set({
          "password": "root",
          "role": 1,
          "team": "Smart Textiles Hub",
          "bpm": 110,
          "latitude": -8.15661,
          "longitude": 117.33280
        });*/

        //await FlutterPhoneDirectCaller.callNumber(emergency_number);

        //ref.child("Pell").update({"emergency_number": "+4915155228855"});
        //ref.child("Pell").update({"personnal_number": "+4915155228855"});

        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationScreen()),
        );*/
      }
      if (index == 2) {
        if (connected == true) {
          print("connecté");
          final usernames =
              await ref.get(); //Here getting the list of members' names
          print(usernames.children.toList().toString());
          usernames.children.forEach((key) {});
          String token = "";
          print(token);
          List<String> admins = await getAdmins(usernames);
          for (String admin in admins) {
            DataSnapshot snapshot = await ref.child(admin).child("token").get();
            token = snapshot.value.toString();
            sendPushMessage(
                token, "$username has sent you an alert.", "Alert!");
            print("Alerte envoyée par $username");
          }
        }
      }
    } catch (e) {
      debugPrint("erreur zebi");
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.purple[900],
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo_sth.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
                Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const Text('SmartTexHub'))
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.purple[800],
          ),
          drawer: Drawer(
            backgroundColor: Colors.purple[900],
            child: SafeArea(
                child: ListView(
              padding: const EdgeInsets.only(left: 0),
              children: [
                SizedBox(
                  height: 100,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.purple[800],
                    ),
                    child: const Text(
                      'Options menu',
                      style: TextStyle(fontSize: 35, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    List<Widget> liste = [];
                    await buildListViewOfEvents()
                        .then((value) => liste = value);
                    if (liste.length > 1) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InfosTeam(liste: liste)),
                      );
                    }
                  },
                  child: const Text(
                    'Team Members',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  height: 30,
                  thickness: 5,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (connected == true) {
                      final pw = await ref.child("$username/password").get();
                      String password = pw.value.toString();
                      final phoneGetter =
                          await ref.child("$username/personnal_number").get();
                      String phone = phoneGetter.value.toString();
                      final emergencyGetter =
                          await ref.child("$username/emergency_number").get();
                      String emergency = emergencyGetter.value.toString();
                      final results = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PersonnalInfo(
                                  username: username,
                                  password: password,
                                  phone: phone,
                                  emergency: emergency,
                                )),
                      );
                      if (results != null) {
                        username = results[0];
                        teamname = results[1];
                        bpm = int.parse(results[2]);
                        emergency_number = results[3];
                      }
                    }
                    setState(() {});
                  },
                  child: const Text(
                    'Personnal Information',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  height: 30,
                  thickness: 5,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (status == 1) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => addMember(team: teamname)),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text(
                                'You don\'t have the permission to access this.')),
                      );
                    }
                  },
                  child: const Text(
                    'Add a member',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  height: 30,
                  thickness: 5,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (status == 1) {
                      final pw = await ref.child("$username/password").get();
                      String password = pw.value.toString();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RemoveMember(
                                team: teamname, password: password)),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                            title: Text(
                                'You don\'t have the permission to access this.')),
                      );
                    }
                  },
                  child: const Text(
                    'Remove a member',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )),
          ),
          body: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    teamname,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 150),
                  Text(
                    bpm.toString(),
                    style: const TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    "BPM",
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.purple[800],
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Connect',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.phone),
                label: 'Emergency call',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                label: 'Send notification',
              )
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ));
  }
}
