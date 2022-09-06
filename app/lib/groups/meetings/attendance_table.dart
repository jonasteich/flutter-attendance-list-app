import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/group_args.dart';

class AttendanceTable extends StatelessWidget {
  const AttendanceTable({Key? key}) : super(key: key);

  static String routeName = '/group/meeting/statistics';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;
    final database = FirebaseDatabase.instance.ref();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.groupName),
      ),
      body: StreamBuilder(
        stream: database
            .child('groups')
            .child(user!.uid)
            .child(args.groupKey)
            .child('meetings')
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final presentUserEachMeeting =
              snapshot.data!.snapshot.children.toList().map((e) {
            return Map.from({
              'name': e.child('name').value as String,
              'presentUsers': e
                  .child('present_members')
                  .children
                  .toList()
                  .map((e) => e.value as String)
                  .toList(),
            });
          }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                stream: database
                    .child('groups')
                    .child(user.uid)
                    .child(args.groupKey)
                    .child('members')
                    .onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final members = snapshot.data?.snapshot.children
                      .toList()
                      .map((e) => e.child('name').value as String)
                      .toList();

                  return Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(
                        children: [
                          const Text(''),
                          for (final meeting in presentUserEachMeeting)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Center(
                                  child: Text(meeting['name']),
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (final member in members!)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(member.split(' ')[0]),
                            ),
                            for (final meeting in presentUserEachMeeting)
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Center(
                                  child:
                                      meeting['presentUsers'].contains(member)
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                ),
                              ),
                          ],
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
