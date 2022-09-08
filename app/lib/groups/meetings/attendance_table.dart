import 'package:app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../models/group_args.dart';

class AttendanceTable extends StatelessWidget {
  const AttendanceTable({Key? key}) : super(key: key);

  static String routeName = '/group/meeting/statistics';

  List<Widget> _buildNameCells(List<String> names) {
    List<Widget> cells = [];
    for (String name in names) {
      cells.add(
        Container(
          height: 30,
          padding: const EdgeInsets.all(2),
          child: Center(
            child: Text('${name.split(' ').first} ${name.split(' ')[1][0]}.'),
          ),
        ),
      );
    }
    return cells;
  }

  List<Widget> _buildAttendanceCells(
    List<String> attendance,
    List<String> members,
    int guests,
  ) {
    List<Widget> cells = [];
    int present = 0;
    for (String member in members) {
      bool isPresent = attendance.contains(member);
      if (isPresent) present++;
      cells.add(
        Container(
          height: 30,
          padding: const EdgeInsets.all(2),
          child: Center(
            child: Icon(
              isPresent ? Icons.check : Icons.close,
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
        ),
      );
    }
    cells.add(
      Container(
        height: 30,
        padding: const EdgeInsets.all(2),
        child: Center(
          child: Text('$guests'),
        ),
      ),
    );
    cells.add(
      Container(
        height: 30,
        padding: const EdgeInsets.all(2),
        child: Center(
          child: Text('${present + guests}'),
        ),
      ),
    );
    return cells;
  }

  List<Widget> _buildAttendanceColumns(
    List<List<String>> attendance,
    List<String> members,
    List<String> dates,
    List<int> guests,
  ) {
    List<Widget> rows = [];
    for (int i = 0; i < attendance.length; i++) {
      rows.add(
        Column(
          children: [
            SizedBox(
              height: 80,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    DateFormat('dd.MM.yy').format(DateTime.parse(dates[i])),
                  ),
                ),
              ),
            ),
            ..._buildAttendanceCells(attendance[i], members, guests[i]),
          ],
        ),
      );
    }
    return rows;
  }

  List<String> _getNames(Iterable<DataSnapshot> members) {
    List<String> names = [];
    members.toList().forEach((member) {
      names.add(member.child('name').value as String);
    });
    return names;
  }

  List<List<String>> _getAttendance(Iterable<DataSnapshot> meetings) {
    List<List<String>> attendance = [];
    meetings.toList().forEach((meeting) {
      final List<String> meetingAttendance = [];
      final Iterable<DataSnapshot> members =
          meeting.child('present_members').children;

      members.toList().forEach((member) {
        meetingAttendance.add(member.value as String);
      });
      attendance.add(meetingAttendance);
    });
    return attendance;
  }

  List<String> _getDates(Iterable<DataSnapshot> meetings) {
    return meetings.map((e) {
      return e.child('date').value as String;
    }).toList();
  }

  List<int> _getGuests(Iterable<DataSnapshot> meetings) {
    return meetings.map((e) {
      return e.child('guests').value as int;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;
    final database = FirebaseDatabase.instance.ref();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.groupName),
      ),
      body: FutureBuilder(
        future: database
            .child('groups')
            .child(user!.uid)
            .child(args.groupKey)
            .child('meetings')
            .once(),
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<List<String>> meetings = _getAttendance(
            snapshot.data!.snapshot.children,
          );
          List<String> dates = _getDates(snapshot.data!.snapshot.children);
          List<int> guests = _getGuests(snapshot.data!.snapshot.children);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: database
                    .child('groups')
                    .child(user.uid)
                    .child(args.groupKey)
                    .child('members')
                    .once(),
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<String> members =
                      _getNames(snapshot.data!.snapshot.children);

                  return Column(
                    children: [
                      SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 80, child: Text('')),
                                ..._buildNameCells(members),
                                Container(
                                  height: 30,
                                  padding: const EdgeInsets.all(2),
                                  child: const Center(
                                    child: Text('Guests'),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  padding: const EdgeInsets.all(2),
                                  child: const Center(
                                    child: Text('Total Visitors'),
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._buildAttendanceColumns(
                                      meetings,
                                      members,
                                      dates,
                                      guests,
                                    ),
                                  ], // Attendance column
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Utils.createExcel(
                          members: members,
                          attendance: meetings,
                          dates: dates,
                          guests: guests,
                        ),
                        child: const Text('Export to Excel'),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
