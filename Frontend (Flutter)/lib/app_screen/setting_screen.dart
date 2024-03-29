import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:term_project/app_screen/first_screen.dart';
import 'package:http/http.dart' as http;

class SettingScreen extends StatefulWidget {
  String morning;
  String noon;
  String evening;
  String sleep;
  // String uid;
  SettingScreen({
    super.key,
    required this.morning,
    required this.noon,
    required this.evening,
    required this.sleep,
  });

  @override
  _SettingScreen createState() => _SettingScreen(
      morning: morning, noon: noon, evening: evening, sleep: sleep);
}

class _SettingScreen extends State<SettingScreen> {
  _SettingScreen({
    required this.morning,
    required this.noon,
    required this.evening,
    required this.sleep,
  });
  final formKey = GlobalKey<FormState>();
  String morning;
  String noon;
  String evening;
  String sleep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าเวลาเเจ้งเตือน"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const FirstScreen();
              }));
            },
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "เวลาเตือนตอนอาหารเช้า",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onChanged: (time) {
                            print("Changing");
                          }, onConfirm: (time) {
                            print("Confirm Time: $time");
                            setState(() {
                              morning = "${time.hour < 10
                                      ? '0${time.hour}'
                                      : time.hour.toString()}:${time.minute < 10
                                      ? '0${time.minute}'
                                      : time.minute.toString()}:${time.second < 10
                                      ? '0${time.second}'
                                      : time.second.toString()}";
                            });
                          });
                        },
                        child: Text("${morning}")),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "เวลาเตือนตอนอาหารกลางวัน",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onChanged: (time) {
                            print("Changing");
                          }, onConfirm: (time) {
                            print("Confirm Time: $time");
                            setState(() {
                              noon = "${time.hour < 10
                                      ? '0${time.hour}'
                                      : time.hour.toString()}:${time.minute < 10
                                      ? '0${time.minute}'
                                      : time.minute.toString()}:${time.second < 10
                                      ? '0${time.second}'
                                      : time.second.toString()}";
                            });
                          });
                        },
                        child: Text("${noon}")),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "เวลาเตือนตอนอาหารเย็น",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onChanged: (time) {
                            print("Changing");
                          }, onConfirm: (time) {
                            print("Confirm Time: $time");
                            setState(() {
                              evening = "${time.hour < 10
                                      ? '0${time.hour}'
                                      : time.hour.toString()}:${time.minute < 10
                                      ? '0${time.minute}'
                                      : time.minute.toString()}:${time.second < 10
                                      ? '0${time.second}'
                                      : time.second.toString()}";
                            });
                          });
                        },
                        child: Text("${evening}")),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "เวลาเตือนตอนเข้านอน",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onChanged: (time) {
                            print("Changing");
                          }, onConfirm: (time) {
                            print("Confirm Time: $time");
                            setState(() {
                              sleep = "${time.hour < 10
                                      ? '0${time.hour}'
                                      : time.hour.toString()}:${time.minute < 10
                                      ? '0${time.minute}'
                                      : time.minute.toString()}:${time.second < 10
                                      ? '0${time.second}'
                                      : time.second.toString()}";
                            });
                          });
                        },
                        child: Text("${sleep}")),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text(
                        "ยืนยันการเลือกเวลา",
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () async {
                        var uid;
                        final user = FirebaseAuth.instance;
                        if (user.currentUser!.uid.isNotEmpty) {
                          uid = user.currentUser!.uid;
                        }
                        var response = await http
                            .post(
                                Uri.parse(
                                    'http://10.0.2.2:8000/updateUserSettingById'),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "uid": uid,
                                  "morning": morning,
                                  "noon": noon,
                                  "evening": evening,
                                  "sleep": sleep
                                }))
                            .then((value) => Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const FirstScreen();
                                })));
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HourAndMinTime {
  int hour;
  int minute;
  HourAndMinTime({required this.hour, required this.minute});
}
