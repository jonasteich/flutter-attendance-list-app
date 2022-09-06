import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateMeetingArgs {
  final String groupName;
  final String groupKey;
  CreateMeetingArgs(this.groupName, this.groupKey);
}

class CreateMeeting extends StatefulWidget {
  const CreateMeeting({Key? key}) : super(key: key);

  static const routeName = '/group/meeting/create';

  @override
  State<CreateMeeting> createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String getTitleString(String date) {
    return DateFormat('dd.MM.yy').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CreateMeetingArgs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Future<DateTime?> date = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    date.then((value) {
                      if (value != null) {
                        setState(() {
                          selectedDate = value;
                        });
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTitleString(selectedDate.toString()),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.edit),
                    ],
                  ),
                ),
              ),
              TextField(
                autofocus: true,
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ], // Content of Modal
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {
            final newMeeting = <String, dynamic>{
              'name': nameController.text,
              'date': selectedDate.toString(),
              'present_members': [],
            };

            try {
              await database
                  .child('groups')
                  .child(user!.uid)
                  .child(args.groupKey)
                  .child('meetings')
                  .push()
                  .set(newMeeting);
              Navigator.of(context).pop();
            } catch (e) {
              print(e);
            }
          },
          child: const Text('Create'),
        ),
      ),
    );
  }
}
