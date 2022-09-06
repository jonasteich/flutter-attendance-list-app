import 'package:app/auth/auth_page.dart';
import 'package:app/auth/login.dart';
import 'package:app/groups/create_group.dart';
import 'package:app/groups/edit_group.dart';
import 'package:app/groups/meetings/attendance_table.dart';
import 'package:app/groups/meetings/create_meeting.dart';
import 'package:app/groups/meetings/eidt_meeting.dart';
import 'package:app/groups/meetings/index.dart';
import 'package:app/groups/meetings/members/create_member.dart';
import 'package:app/groups/meetings/members/index.dart';
import 'package:app/groups/index.dart';
import 'package:app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      navigatorKey: navigatorKey,
      routes: {
        GroupPage.routeName: (context) => const GroupPage(),
        MeetingPage.routeName: (context) => const MeetingPage(),
        CreateMeeting.routeName: (context) => const CreateMeeting(),
        CreateMember.routeName: (context) => const CreateMember(),
        CreateGroup.routeName: (context) => const CreateGroup(),
        AttendanceTable.routeName: (context) => const AttendanceTable(),
        EditGroup.routeName: (context) => const EditGroup(),
        EditMeeting.routeName: (context) => const EditMeeting(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return const Text('Something went wrong');
          } else if (snapshot.hasData) {
            return const RootPage();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
