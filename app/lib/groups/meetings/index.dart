import 'package:app/groups/meetings/attendance_table.dart';
import 'package:app/groups/meetings/create_meeting.dart';
import 'package:app/groups/meetings/members/index.dart';
import 'package:app/models/group_args.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';

import 'eidt_meeting.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  static const routeName = '/group';

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AttendanceTable.routeName,
                arguments: args,
              );
            },
          ),
        ],
      ),
      body: MeetingsList(database: _database, user: user, args: args),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            CreateMeeting.routeName,
            arguments: CreateMeetingArgs(args.groupName, args.groupKey),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MeetingsList extends StatelessWidget {
  const MeetingsList({
    Key? key,
    required DatabaseReference database,
    required this.user,
    required this.args,
  })  : _database = database,
        super(key: key);

  final DatabaseReference _database;
  final User? user;
  final GroupArgs args;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _database
          .child('groups')
          .child(user!.uid)
          .child(args.groupKey)
          .child('meetings')
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData) {
          List<Map<String, dynamic>> meetings =
              snapshot.data!.snapshot.children.toList().map((e) {
            return Map<String, dynamic>.from({
              'date': e.child('date').value,
              'name': e.child('name').value,
              'key': e.key,
            });
          }).toList();

          return ListView(
            children: [
              for (var meeting in meetings)
                ListTile(
                  title: Text(getTitleString(meeting['date'], meeting['name'])),
                  trailing: FocusedMenuHolder(
                    menuItems: [
                      FocusedMenuItem(
                        title: const Text('Rename'),
                        trailingIcon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            EditMeeting.routeName,
                            arguments: GroupArgs(
                              groupKey: args.groupKey,
                              groupName: args.groupName,
                              meetingKey: meeting['key'],
                              meetingName: meeting['name'],
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
                          _deleteMeeting(meeting['key']);
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
                      MeetingPage.routeName,
                      arguments: GroupArgs(
                        meetingKey: meeting['key'],
                        meetingName: meeting['name'],
                        groupName: args.groupName,
                        groupKey: args.groupKey,
                      ),
                    );
                  },
                ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _deleteMeeting(String key) {
    _database
        .child('groups')
        .child(user!.uid)
        .child(args.groupKey)
        .child('meetings')
        .child(key)
        .remove();
  }
}

String getTitleString(String date, String name) {
  return '${DateFormat('dd.MM.yy').format(DateTime.parse(date))} - $name';
}
