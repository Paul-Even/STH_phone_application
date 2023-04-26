// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sth_app/map_screen.dart';

import 'firebase_options.dart'; //Packages used for the database installation
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_messaging/firebase_messaging.dart'; //Packages used for sending notificaions
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart'; //Package used to make calls

import 'connection_menu.dart'; //Importing the screens created in other files
import 'info_team.dart';
import 'personnal_infos_modify.dart';
import 'add_member.dart';
import 'remove_member.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Linking the application to the Firebase database & messaging services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Textiles Hub',
      theme: ThemeData(
          //primarySwatch: Colors.blue,
          ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  //This creates the home page widget
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); //Initialize the notification plugin

  initInfo() {
    //Function to show a notification when one is received
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

  DatabaseReference ref = FirebaseDatabase.instance
      .ref("members"); //Gets the database "members" node's adress

  String username = "Not connected"; //Value to display the user's name
  String teamname = ""; //Value to display the user's team's name
  String emergency_number = ""; //The number to call in emergency
  bool connected = false; //Boolean to check if the user is connected or not
  int status =
      2; //Value to check if the user is a team administrator or not (1 if admin)
  List<String> members = []; //Array to store all the members in the database
  @override
  void initState() {
    super.initState();
    _listenBPM(); //Updates the BPM value when it is modified
    requestPermission(); //Asking the user for the permission to send notifications
    initInfo(); //Function to show a notification when one is received
  }

  void _listenBPM() {
    //Updates the BPM value shown when it is modified
    if (connected == true) {
      //Listens only if the user is connected
      ref.child(username).child("bpm").onValue.listen((event) async {
        int bpm = int.parse(event.snapshot.value
            .toString()); //Stores the value recovered from the database
        if (bpm < 50 || bpm > 160) {
          //Checks if the BPM is normal or if there's an emergency, in the second case, sends an automatic notification to the admins
          final usernames =
              await ref.get(); //Here getting the list of members' names

          String token = ""; //Stores the token
          List<String> admins = await getAdmins(
              usernames); //Gets the admins in the list of members
          for (String admin in admins) {
            //Sends a notification to every admin in the list
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
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //Opens or closes the main page drawer

  int _selectedIndex = 1;

  int bpm = 0; //Value to display the user's BPM

  Future<List<String>> getMembers(DataSnapshot username) async {
    //Get every member from the same team as the user
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
      //Classes members by alphabetical order
      (a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()),
    );
    return members;
  }

  Future<List<String>> getAdmins(DataSnapshot username) async {
    //Get every admin from the same team as the user
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
          //Checks every members' role
          setState(() {
            members.add(key.key.toString());
          });
        }
      }
    });
    return members;
  }

  Future<String> getRole(DatabaseReference ref, String path) async {
    //Gets a user's role
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
    //Gets a user's BPM
    final dataBPM = await ref.child(path).get();
    return int.parse(dataBPM.value.toString());
  }

  Future<double> getLatitude(DatabaseReference ref, String path) async {
    //Gets a user's latitude
    final dataLat = await ref.child(path).get();
    return double.parse(dataLat.value.toString());
  }

  Future<double> getLongitude(DatabaseReference ref, String path) async {
    //Gets a user's latitude
    final dataLon = await ref.child(path).get();
    return double.parse(dataLon.value.toString());
  }

  Future<String> getPhone(DatabaseReference ref, String path) async {
    //Gets a user's personnal phone number
    final dataPhone = await ref.child(path).get();
    return dataPhone.value.toString();
  }

  Future<List<Container>> getContainers(
      //Creates the list of widgets needed to display the information of one member
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
                            "Name : $name", //Displays the member's name
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Role : ${role.toString()}", //Displays the member's role
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            "BPM : ${bpm.toString()}", //Displays the member's BPM
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
                                //Displaying a button to call the member
                                iconSize: 50,
                                color: Colors.white,
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      phone);
                                },
                                icon: const Icon(Icons.phone)),
                            IconButton(
                                //Displaying a button to see the member's location
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
    //Creates the list of widgets needed to display the information of every member
    //Building the list's view

    final username =
        await ref.get(); //Getting the list of every person in the database
    List<Container> containers = <Container>[];

    members = await getMembers(
        username); //Getting the list of every member of the user's team

    for (int i = 0; i < members.length; i++) {
      //Create a container for every member in the list
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
      //Put all the containers in one column
      Column(),
      ...containers,
    ];
  }

  void _onItemTapped(int index) async {
    //Defines the action made bu the bottom bar's buttons
    try {
      if (index == 0) {
        //If the user clicks on the left button
        final result = await Navigator.push(
          //Opens the connection menu
          context,
          MaterialPageRoute(builder: (context) => const ConnectionMenu()),
        );
        if (result != null) {
          //If the user connected, retrieves the useful values
          username = result[0];
          teamname = result[1];
          status = int.parse(result[2]);
          bpm = int.parse(result[3]);
          emergency_number = result[4];
          connected = true;
        }
      }
      if (index == 1) {
        //If the user clicks on the middle button
        if (emergency_number != "") {
          await FlutterPhoneDirectCaller.callNumber(
              emergency_number); //Calls the defined emergency number, if one is defined
        }
      }
      if (index == 2) {
        //If the user clicks on the right button
        if (connected == true) {
          //Checks if the user is connected
          final usernames =
              await ref.get(); //Getting the list of members' names
          usernames.children.forEach((key) {});
          String token = "";
          List<String> admins = await getAdmins(usernames);
          for (String admin in admins) {
            //Sends a notification to every admin on the member's team
            DataSnapshot snapshot = await ref.child(admin).child("token").get();
            token = snapshot.value.toString();
            sendPushMessage(
                token, "$username has sent you an alert.", "Alert!");
          }
        }
      }
    } catch (e) {
      debugPrint("BottomNavigationBar error");
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
          backgroundColor:
              Colors.purple[900], //Sets the screen's background color
          appBar: AppBar(
            //Creates the page's top bar
            leading: IconButton(
                //Button the open the drawer, where different options are available
                onPressed: () => _scaffoldKey.currentState
                    ?.openDrawer(), //Opens the drawer when the button is clicked
                icon: const Icon(Icons.menu)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  //Shows the STH logo
                  'assets/logo_sth.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
                Container(
                    //Contains the top bar title
                    padding: const EdgeInsets.all(10.0),
                    child: const Text('SmartTexHub'))
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.purple[800], //Sets the top bar color
          ),
          drawer: Drawer(
            //Creates the drawer
            backgroundColor:
                Colors.purple[900], //Sets the drawer's background color
            child: SafeArea(
                //Creates the drawer's title
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
                      'Options menu', //Drawer's title
                      style: TextStyle(fontSize: 35, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  //Button to see the list of team members
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
                  // Button to change the user's personnal information
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (connected == true) {
                      final pw = await ref
                          .child("$username/password")
                          .get(); //Gets the user's password
                      String password = pw.value.toString();
                      final phoneGetter = await ref
                          .child("$username/personnal_number")
                          .get(); //Gets the user's defined phone number
                      String phone = phoneGetter.value.toString();
                      final emergencyGetter = await ref
                          .child("$username/emergency_number")
                          .get(); //Gets the user's defined emergency number
                      String emergency = emergencyGetter.value.toString();
                      final results = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            //Opens the information modification page
                            builder: (context) => PersonnalInfo(
                                  username: username,
                                  password: password,
                                  phone: phone,
                                  emergency: emergency,
                                )),
                      );
                      if (results != null) {
                        //Retrieves the changed values
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
                  //Button to add a member (only for admins)
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (status == 1) {
                      //Checks if the user is logged as an admin
                      await Navigator.push(
                        //Opens the member adding page
                        context,
                        MaterialPageRoute(
                            builder: (context) => addMember(team: teamname)),
                      );
                    } else {
                      //Show a popup message if the user is not logged as an admin
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
                  //Button to remove a member from the team (only for admins)
                  style: TextButton.styleFrom(
                    alignment: Alignment.topLeft,
                    textStyle: const TextStyle(fontSize: 35),
                  ),
                  onPressed: () async {
                    if (status == 1) {
                      //Checks if the user is logged as an admin
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
            //Main page container
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  Text(
                    username, //Displays the user's name
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    teamname, //Displays the user's team name
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 150),
                  Text(
                    bpm.toString(), //Displays user's BPM value
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
            //Creates the bottom bar
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.purple[800],
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                //Button to connect
                icon: Icon(Icons.person),
                label: 'Connect',
              ),
              BottomNavigationBarItem(
                //Button to make an emergency call
                icon: Icon(Icons.phone),
                label: 'Emergency call',
              ),
              BottomNavigationBarItem(
                //Button to send a notification to the team's admins
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
