import 'package:booking_group_flutter/add_new_task.dart';
import 'package:booking_group_flutter/utils.dart';
import 'package:booking_group_flutter/widgets/date_selector.dart';
import 'package:booking_group_flutter/widgets/task_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              logout();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('My Tasks'),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddNewTask()),
              );
            },
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const DateSelector(),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      const Expanded(
                        child: TaskCard(
                          color: Color.fromRGBO(246, 222, 194, 1),
                          headerText: 'My humor upsets me XD',
                          descriptionText: 'My humor not that great:(',
                          scheduledDate: '69th August, 4020',
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: strengthenColor(
                            const Color.fromRGBO(246, 222, 194, 1),
                            0.69,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('10:00AM', style: TextStyle(fontSize: 17)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
