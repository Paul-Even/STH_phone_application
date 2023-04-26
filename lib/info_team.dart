// ignore_for_file: must_be_immutable, camel_case_types, avoid_unnecessary_containers

import 'package:flutter/material.dart';

class InfosTeam extends StatelessWidget {
  List<Widget> liste = [];
  InfosTeam({super.key, required this.liste});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple[800],
          title: Row(children: const <Widget>[
            Text(
              'Team Members',
              textAlign: TextAlign.center,
            ),
          ])),
      body: teamInfos(liste: liste),
    );
  }
}

class teamInfos extends StatefulWidget {
  List<Widget> liste = []; //Recovers the widget list
  teamInfos({super.key, required this.liste});

  @override
  State<teamInfos> createState() => _teamInfosState();
}

class _teamInfosState extends State<teamInfos> {
  @override
  void initState() {
    super.initState();
  }

  ListView _buildListViewOfEvents(List<Widget> liste) {
    //Building the list's view with the given containers
    List<Container> containers = <Container>[];
    containers.add(
      Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(children: liste),
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

  Widget _buildView(liste) {
    return _buildListViewOfEvents(liste);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildView(widget.liste),
        backgroundColor: Colors.purple[900],
      );
}
