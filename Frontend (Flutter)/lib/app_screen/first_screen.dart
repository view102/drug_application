import 'dart:convert';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:multiselect/multiselect.dart';
import 'package:term_project/Object/Drug.dart';
import 'package:term_project/Object/UserSetting.dart';
import 'package:term_project/app_screen/auth_screen/auth_screen.dart';
import 'package:term_project/app_screen/manual_form.dart';
import 'package:term_project/app_screen/second_screen.dart';
import 'package:term_project/app_screen/setting_screen.dart';
import 'package:term_project/app_screen/third_screen.dart';

import 'camera_screen/camera_controller.dart';
import 'notification/Notify.dart';

// ส่วนของ Stateful widget
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FirstScreen();
  }
}

class _FirstScreen extends State<FirstScreen> {
  late Future<List<Drug>> drugs;
  late Future<UserSetting> userSettingFuture;
  late UserSetting userSetting;

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    userSettingFuture = fetchUserSetting();
    drugs = fetchDrug();
    userSettingFuture.then((value) {
      userSetting = value;
      drugs.then((value) {
        setSchedule(drugs, userSetting);
      });
    });
    // print(userSetting);
    print(drugs);
    print("finish initState");
  }

  void _refreshData() {
    setState(() {
      print("setState"); // สำหรับทดสอบ
      drugs = fetchDrug();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Drug Application'),
            backgroundColor: Colors.green,
            bottom: const TabBar(
              // ส่วนของ tab
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.history)),
                Tab(icon: Icon(Icons.search)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Setting',
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return SettingScreen(
                          morning: userSetting.morning,
                          noon: userSetting.noon,
                          evening: userSetting.evening,
                          sleep: userSetting.sleep);
                    }));
                  }),
              IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  tooltip: 'Favorite List',
                  onPressed: () {
                    final user = FirebaseAuth.instance;
                    user.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return const AuthScreen();
                    }));
                  }),
            ],
          ),
          body: TabBarView(
            children: [
              Container(
                  child: FutureBuilder<List<Drug>>(
                future: drugs,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // กรณีมีข้อมูล
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        print(snapshot.data);
                        return _buildRow(snapshot.data, index, userSetting);
                      },
                    );
                  } else if (snapshot.hasError) {
                    // กรณี error
                    return Text('ERROR_SNAPSHOT: ${snapshot.error}');
                  }
                  // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
                  return const Center(
                    child: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              )),
              const SecondScreen(),
              const ThirdScreen(),
            ],
          ),
          floatingActionButton: PopupMenuButton(
            onSelected: (value) async {
              if (value == 1) {
                await availableCameras().then((cameras) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return CameraPage(cameras: cameras);
                  }));
                });
              } else if (value == 2) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const ManualForm();
                }));
              }
            },
            color: Colors.green,
            icon: const Icon(Icons.add),
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem(
                  value: 1,
                  child: Text("Scan"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Manual"),
                )
              ];
            },
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Colors.green,
          //   onPressed: () async {
          //     await availableCameras().then((value) {
          //       print("cameras: $value");
          //       Navigator.pushReplacement(
          //           context,
          //           MaterialPageRoute(
          //               builder: (_) => CameraPage(cameras: value)));
          //     });
          //   },
          //   child: const Icon(Icons.add),
          // ),
        ));
  }

  Widget _buildRow(drug, index, userSetting) {
    bool isEditing = false;
    bool hidingTimes = true;
    var listOfTimes = drug[index].times;
    if (drug[index].typeOfAlarm == "routine") {
      return StatefulBuilder(builder: (context, setStateCard) {
        return Container(
            child: Card(
                margin: const EdgeInsets.all(5.0), // การเยื้องขอบ
                child: Column(
                  children: [
                    ListTile(
                        leading: IconButton(
                            onPressed: () {
                              setStateCard(() {
                                hidingTimes = !hidingTimes;
                              });
                            },
                            icon: Icon(Icons.arrow_drop_down_circle)),
                        title: Text(drug[index].drugName),
                        subtitle: Text(
                          "${drug[index].createDate} (${drug[index].typeOfAlarm})",
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                        trailing: TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    List<String> times = [
                                      'เช้า',
                                      'กลางวัน',
                                      'เย็น',
                                      'ก่อนนอน'
                                    ];
                                    var dict = {
                                      "เช้า": "morning",
                                      "กลางวัน": "noon",
                                      "เย็น": "evening",
                                      "ก่อนนอน": "sleep",
                                      "ก่อนอาหาร": "beforeMeal",
                                      "หลังอาหาร": "afterMeal"
                                    };
                                    var dict_inverse = {
                                      "morning": "เช้า",
                                      "noon": "กลางวัน",
                                      "evening": "เย็น",
                                      "sleep": "ก่อนนอน",
                                      "beforeMeal": "ก่อนอาหาร",
                                      "afterMeal": "หลังอาหาร"
                                    };
                                    List<String> selectedTimes = [];
                                    for (var item in drug[index].times) {
                                      selectedTimes
                                          .add(dict_inverse[item].toString());
                                    }
                                    var timesInDialog = drug[index].manualTimes;
                                    timesInDialog.sort((a, b) {
                                      return compareTime(a, b);
                                    });
                                    return StatefulBuilder(
                                        builder: (context, setStateDialog) {
                                      return SimpleDialog(
                                        title: Text('Edit Alarm'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: DropDownMultiSelect(
                                              whenEmpty: 'Select Something',
                                              options: times,
                                              selectedValues: selectedTimes,
                                              onChanged: (value) {
                                                debugPrint(
                                                    'selected times $value');
                                                setStateDialog(() {
                                                  List<String> temp = [];
                                                  for (var item in value) {
                                                    temp.add(
                                                        dict[item].toString());
                                                  }
                                                  selectedTimes = value;
                                                });
                                                debugPrint(
                                                    'you have selected $selectedTimes times.');
                                              },
                                            ),
                                          ),
                                          ButtonBar(
                                            children: [
                                              TextButton(
                                                  onPressed: () async {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Delete Drug'),
                                                            content: Text(
                                                                'ต้องการลบยาตัวนี้ใช้หรือไม่ ?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                    'ยกเลิก'),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await http
                                                                      .post(
                                                                          Uri.parse(
                                                                              'http://10.0.2.2:8000/deleteDrugById'),
                                                                          headers: {
                                                                            "Content-Type":
                                                                                "application/json"
                                                                          },
                                                                          body:
                                                                              jsonEncode({
                                                                            "drugId":
                                                                                drug[index].drugId,
                                                                            "lastDate":
                                                                                DateTime.now().toString()
                                                                          }))
                                                                      .then((value) => Navigator.pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => const FirstScreen())));
                                                                },
                                                                child: Text(
                                                                    'ยืนยัน'),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  child: Text("remove")),
                                              TextButton(
                                                  onPressed: () async {
                                                    var temp = [];
                                                    for (var t
                                                        in selectedTimes) {
                                                      temp.add(dict[t]);
                                                    }
                                                    await http
                                                        .post(
                                                            Uri.parse(
                                                                'http://10.0.2.2:8000/updateTimes'),
                                                            headers: {
                                                              "Content-Type":
                                                                  "application/json"
                                                            },
                                                            body: jsonEncode({
                                                              "drugId":
                                                                  drug[index]
                                                                      .drugId,
                                                              "times": temp
                                                            }))
                                                        .then((value) => Navigator
                                                            .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const FirstScreen())));
                                                  },
                                                  child: Text("confirm")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("cancel"))
                                            ],
                                          )
                                        ],
                                      );
                                    });
                                  });
                            },
                            child: Text("Edit"))),
                    Visibility(
                      visible: !hidingTimes,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            children: List.generate(drug[index].times.length,
                                (index2) {
                              var t;
                              if (drug[index].times[index2] == 'morning') {
                                t = userSetting.morning;
                              } else if (drug[index].times[index2] == 'noon') {
                                t = userSetting.noon;
                              } else if (drug[index].times[index2] ==
                                  'evening') {
                                t = userSetting.evening;
                              } else {
                                t = userSetting.sleep;
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              );
                            }),
                          )),
                    ),
                  ],
                )));
      });
    } else {
      return StatefulBuilder(builder: (context, setStateCard) {
        return Container(
            child: Card(
                margin: const EdgeInsets.all(5.0), // การเยื้องขอบ
                child: Column(
                  children: [
                    ListTile(
                        leading: IconButton(
                            onPressed: () {
                              setStateCard(() {
                                hidingTimes = !hidingTimes;
                              });
                            },
                            icon: Icon(Icons.arrow_drop_down_circle)),
                        title: Text(drug[index].drugName),
                        subtitle: Text(
                          "${drug[index].createDate} (${drug[index].typeOfAlarm})",
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  var timesInDialog = drug[index].manualTimes;
                                  timesInDialog.sort((a, b) {
                                    return compareTime(a, b);
                                  });
                                  return StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                    return SimpleDialog(
                                      title: Text('Edit Alarm'),
                                      children: [
                                        for (var i = 0;
                                            i < timesInDialog.length;
                                            i++)
                                          ListTile(
                                              title: Text(timesInDialog[i]),
                                              trailing: TextButton(
                                                  onPressed: () {
                                                    setStateDialog(() {
                                                      timesInDialog.removeAt(i);
                                                    });
                                                  },
                                                  child: Text("remove"))),
                                        TextButton(
                                            onPressed: () {
                                              DatePicker.showTimePicker(context,
                                                  showTitleActions: true,
                                                  onChanged: (time) {
                                                print("Changing");
                                              }, onConfirm: (time) {
                                                print("Confirm Time: $time");
                                                setStateDialog(() {
                                                  timesInDialog.add(
                                                      "${time.hour < 10 ? '0${time.hour}' : time.hour.toString()}:${time.minute < 10 ? '0${time.minute}' : time.minute.toString()}:${time.second < 10 ? '0${time.second}' : time.second.toString()}");
                                                });
                                              });
                                            },
                                            child: Text("เพิ่มเวลา")),
                                        ButtonBar(
                                          children: [
                                            TextButton(
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Delete Drug'),
                                                          content: Text(
                                                              'ต้องการลบยาตัวนี้ใช้หรือไม่ ?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  'ยกเลิก'),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await http
                                                                    .post(
                                                                        Uri.parse(
                                                                            'http://10.0.2.2:8000/deleteDrugById'),
                                                                        headers: {
                                                                          "Content-Type":
                                                                              "application/json"
                                                                        },
                                                                        body:
                                                                            jsonEncode({
                                                                          "drugId":
                                                                              drug[index].drugId,
                                                                          "lastDate":
                                                                              DateTime.now().toString()
                                                                        }))
                                                                    .then(
                                                                        (value) {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const FirstScreen()));
                                                                });
                                                              },
                                                              child: Text(
                                                                  'ยืนยัน'),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Text("remove")),
                                            TextButton(
                                                onPressed: () async {
                                                  await http
                                                      .post(
                                                          Uri.parse(
                                                              'http://10.0.2.2:8000/updateManualTimes'),
                                                          headers: {
                                                            "Content-Type":
                                                                "application/json"
                                                          },
                                                          body: jsonEncode({
                                                            "drugId":
                                                                drug[index]
                                                                    .drugId,
                                                            "manualTimes":
                                                                timesInDialog
                                                          }))
                                                      .then((value) => Navigator
                                                          .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const FirstScreen())));
                                                },
                                                child: Text("confirm")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("cancel"))
                                          ],
                                        )
                                      ],
                                    );
                                  });
                                });
                          },
                          child: Text("Edit"),
                        )),
                    Visibility(
                      visible: !hidingTimes,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            children: List.generate(
                                drug[index].manualTimes.length, (index2) {
                              var t = drug[index].manualTimes[index2];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              );
                            }),
                          )),
                    ),
                  ],
                )));
      });
    }
  }
}

// สรัางฟังก์ชั่นดึงข้อมูล คืนค่ากลับมาเป็นข้อมูล Future ประเภท List ของ Article
Future<List<Drug>> fetchDrug() async {
  var uid;
  final user = FirebaseAuth.instance;
  if (user.currentUser!.uid.isNotEmpty) {
    uid = user.currentUser!.uid;
  }

  //Ios
  // var response = await http.post(Uri.parse('http://127.0.0.1:8000/getDrugById'),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "uid": uid,
  //     }));

  //Android
  var response = await http.post(Uri.parse('http://10.0.2.2:8000/getDrugById'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
      }));

  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    print(response.body);

    // ส่งข้อมูลที่เป็น JSON String data ไปทำการแปลง เป็นข้อมูล List<Article
    // โดยใช้คำสั่ง compute ทำงานเบื้องหลัง เรียกใช้ฟังก์ชั่นชื่อ parseArticles
    // ส่งข้อมูล JSON String data ผ่านตัวแปร response.body
    var result = compute(parseDrug, response.body);
    return result;
  } else {
    // กรณี error
    print("2");
    throw Exception('Failed to load article');
  }
}

// ฟังก์ชั่นแปลงข้อมูล JSON String data เป็น เป็นข้อมูล List<Article>
List<Drug> parseDrug(String responseBody) {
  print("parseDrug");
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  print(parsed.map<Drug>((json) => Drug.fromJson(json)).toList().toString());
  return parsed.map<Drug>((json) => Drug.fromJson(json)).toList();
}

Future<UserSetting> fetchUserSetting() async {
  var uid;
  final user = FirebaseAuth.instance;
  if (user.currentUser!.uid.isNotEmpty) {
    uid = user.currentUser!.uid;
  }

  //Ios
  // var response = await http.post(Uri.parse('http://127.0.0.1:8000/getDrugById'),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "uid": uid,
  //     }));

  //Android
  var response =
      await http.post(Uri.parse('http://10.0.2.2:8000/getUserSetting'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "uid": uid,
          }));

  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    print(response.body);
    final data = jsonDecode(response.body);
    print(data);
    return UserSetting.fromJson(data);
  } else {
    // กรณี error
    print("2");
    throw Exception('Failed to load article');
  }
}

void setSchedule(Future<List<Drug>> drugs, UserSetting userSetting) {
  drugs.then((listOfDrug) async {
    await NotificationService().cancelNotification().then((value) {
      var count = 0;
      for (var drug in listOfDrug) {
        if (drug.typeOfAlarm == "routine") {
          if (drug.times.contains("morning")) {
            var time = userSetting.morning.split(":");
            var hour = time[0];
            var min = time[1];
            NotificationService().scheduleNotification(
              id: count,
              hour: int.parse(hour),
              min: int.parse(min),
              title: "Ready to eat ${drug.drugName} at morning !!!",
              body: "Don't forget to eat medicine",
            );
            count++;
          }
          if (drug.times.contains("noon")) {
            var time = userSetting.noon.split(":");
            var hour = time[0];
            var min = time[1];
            NotificationService().scheduleNotification(
              id: count,
              hour: int.parse(hour),
              min: int.parse(min),
              title: "Ready to eat ${drug.drugName} at noon !!!",
              body: "Don't forget to eat medicine",
            );
            count++;
          }
          if (drug.times.contains("evening")) {
            var time = userSetting.evening.split(":");
            var hour = time[0];
            var min = time[1];
            NotificationService().scheduleNotification(
              id: count,
              hour: int.parse(hour),
              min: int.parse(min),
              title: "Ready to eat ${drug.drugName} at evening !!!",
              body: "Don't forget to eat medicine",
            );
            count++;
          }
          if (drug.times.contains("sleep")) {
            var time = userSetting.sleep.split(":");
            var hour = time[0];
            var min = time[1];
            NotificationService().scheduleNotification(
              id: count,
              hour: int.parse(hour),
              min: int.parse(min),
              title: "Ready to eat ${drug.drugName} at night !!!",
              body: "Don't forget to eat medicine",
            );
            count++;
          }
        } else if (drug.typeOfAlarm == "manual") {
          for (var t in drug.manualTimes) {
            var time = t.split(":");
            var hour = time[0];
            var min = time[1];
            NotificationService().scheduleNotification(
              id: count,
              hour: int.parse(hour),
              min: int.parse(min),
              title: "Ready to eat ${drug.drugName}!!!",
              body: "Don't forget to eat medicine",
            );
            count++;
          }
        }
      }
    });
  });
}

int compareTime(a, b) {
  var listA = a.split(":");
  var listB = b.split(":");
  if (int.parse(listA[0]) < int.parse(listB[0])) {
    return 0;
  } else if (int.parse(listA[0]) > int.parse(listB[0])) {
    return 1;
  } else {
    if (int.parse(listA[1]) < int.parse(listB[1])) {
      return 0;
    } else if (int.parse(listA[1]) > int.parse(listB[1])) {
      return 1;
    } else {
      if (int.parse(listA[2]) < int.parse(listB[2])) {
        return 0;
      } else if (int.parse(listA[2]) > int.parse(listB[2])) {
        return 1;
      } else {
        return 0;
      }
    }
  }
}
