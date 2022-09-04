import 'dart:async';

import 'package:app/groups/meetings/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'create_group.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _database = FirebaseDatabase.instance.ref();
  late StreamSubscription _groupsStream;

  List<Map<String, String>> groups = [];

  @override
  void initState() {
    super.initState();
    _activeListeners();
  }

  void _activeListeners() {
    _groupsStream = _database.child('/groups/${user!.uid}/').onValue.listen(
      (event) {
        groups = [];
        event.snapshot.children.toList().forEach((element) {
          setState(() {
            groups.add(Map.from({
              'key': element.key,
              'name': element.child('name').value as String,
            }));
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(groups[index]['name']!),
            leading: const Icon(Icons.group),
            onTap: () {
              Navigator.pushNamed(
                context,
                GroupPage.routeName,
                arguments: GroupPageArgs(
                  groups[index]['name']!,
                  groups[index]['key']!,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CreateGroup.routeName,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void deactivate() {
    _groupsStream.cancel();
    super.deactivate();
  }
}
