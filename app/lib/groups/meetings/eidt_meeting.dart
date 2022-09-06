import 'package:app/models/group_args.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditMeeting extends StatefulWidget {
  const EditMeeting({Key? key}) : super(key: key);

  static String routeName = '/group/edit';

  @override
  State<EditMeeting> createState() => _EditMeetingState();
}

class _EditMeetingState extends State<EditMeeting> {
  final _database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GroupArgs;
    final nameController = TextEditingController(text: args.meetingName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          autofocus: true,
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name',
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            _database
                .child('groups')
                .child(user!.uid)
                .child(args.groupKey)
                .child('meetings')
                .child(args.meetingKey!)
                .update({'name': nameController.text});
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ),
    );
  }
}
