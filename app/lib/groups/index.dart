import 'dart:async';

import 'package:app/groups/edit_group.dart';
import 'package:app/groups/meetings/index.dart';
import 'package:app/models/group_args.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

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
            trailing: FocusedMenuHolder(
              menuItems: [
                FocusedMenuItem(
                  title: const Text('Rename'),
                  trailingIcon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      EditGroup.routeName,
                      arguments: GroupArgs(
                        groupKey: groups[index]['key']!,
                        groupName: groups[index]['name']!,
                      ),
                    );
                  },
                ),
                FocusedMenuItem(
                  title: const Text('Delete'),
                  trailingIcon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _deleteGroup(groups[index]['key']!);
                  },
                )
              ],
              openWithTap: true,
              onPressed: () {},
              blurBackgroundColor: Colors.grey,
              child: const Icon(Icons.more_vert),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                GroupPage.routeName,
                arguments: GroupArgs(
                  groupName: groups[index]['name']!,
                  groupKey: groups[index]['key']!,
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

  void _deleteGroup(String key) {
    _database.child('/groups/${user!.uid}/$key').remove();
  }

  @override
  void deactivate() {
    _groupsStream.cancel();
    super.deactivate();
  }
}
