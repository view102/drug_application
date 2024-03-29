import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:multiselect/multiselect.dart';
import 'package:term_project/Object/Drug.dart';
import 'package:http/http.dart' as http;
import 'package:term_project/app_screen/first_screen.dart';

class ManualForm extends StatefulWidget {
  const ManualForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ManualForm();
  }
}

class _ManualForm extends State<ManualForm> {
  List<String> timesForManual = [];
  bool isRoutineType = true;
  final user = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  Drug drug = Drug(
      typeOfAlarm: "",
      drugId: "",
      uid: "",
      drugName: "",
      times: [],
      acts: [],
      createDate: DateTime.now().toString(),
      manualTimes: []);
  List<String> times = ['เช้า', 'กลางวัน', 'เย็น', 'ก่อนนอน'];
  List<String> selectedTimes = [];
  List<String> acts = ['ก่อนอาหาร', 'หลังอาหาร', 'ก่อนนอน'];
  List<String> selectedActs = [];
  var dict = {
    "เช้า": "morning",
    "กลางวัน": "noon",
    "เย็น": "evening",
    "ก่อนนอน": "sleep",
    "ก่อนอาหาร": "beforeMeal",
    "หลังอาหาร": "afterMeal"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มยา"),
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
                    "ชื่อยา",
                    style: TextStyle(fontSize: 20),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: RequiredValidator(errorText: "กรุณาใส่ชื่อยา"),
                    onSaved: (String? name) {
                      drug.drugName = name!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "ประเภทการเเจ้งเตือน",
                    style: TextStyle(fontSize: 20),
                  ),
                  DropdownButton(
                      value: isRoutineType ? 'กินตามมื้ออาหาร' : 'กำหนดเอง',
                      items: <String>['กินตามมื้ออาหาร', 'กำหนดเอง']
                          .map<DropdownMenuItem<String>>((value) {
                        return new DropdownMenuItem(
                            child: Text(value), value: value);
                      }).toList(),
                      onChanged: (value) {
                        if (value == 'กินตามมื้ออาหาร') {
                          setState(() {
                            isRoutineType = true;
                            debugPrint("$isRoutineType");
                          });
                        } else if (value == 'กำหนดเอง') {
                          setState(() {
                            isRoutineType = false;
                            debugPrint("$isRoutineType");
                          });
                        }
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: isRoutineType,
                    child: const Text(
                      "เวลา",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Visibility(
                    visible: isRoutineType,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropDownMultiSelect(
                        whenEmpty: 'Select Something',
                        options: times,
                        selectedValues: selectedTimes,
                        onChanged: (value) {
                          debugPrint('selected times $value');
                          setState(() {
                            List<String> temp = [];
                            for (var item in value) {
                              temp.add(dict[item].toString());
                            }
                            selectedTimes = value;
                            drug.times = temp;
                          });
                          debugPrint('you have selected $selectedTimes times.');
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isRoutineType,
                    child: const Text(
                      "กินตอนไหน",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Visibility(
                    visible: isRoutineType,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropDownMultiSelect(
                        whenEmpty: 'Select Something',
                        options: acts,
                        selectedValues: selectedActs,
                        onChanged: (value) {
                          debugPrint('selected acts $value');
                          setState(() {
                            List<String> temp = [];
                            for (var item in value) {
                              temp.add(dict[item].toString());
                            }
                            selectedActs = value;
                            drug.acts = temp;
                          });
                          debugPrint('you have selected $selectedActs acts.');
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isRoutineType,
                    child: const Text(
                      "เวลาเเจ้งเตือน",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Visibility(
                    visible: !isRoutineType,
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black)),
                        child: Wrap(children: [
                          for (var i in timesForManual)
                            Card(
                              child: Text(
                                "$i",
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                        ]),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setStateModal) {
                                  List<String> modalTime = timesForManual;
                                  modalTime.sort((a, b) {
                                    return compareTime(a, b);
                                  });
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.separated(
                                                itemCount: modalTime.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title:
                                                        Text(modalTime[index]),
                                                    subtitle: Text("alarm"),
                                                    trailing: ElevatedButton(
                                                      onPressed: () {
                                                        setStateModal(() {
                                                          modalTime
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      style: const ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStatePropertyAll<
                                                                      Color>(
                                                                  Color.fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255))),
                                                      child: const Text(
                                                        "remove",
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    242,
                                                                    122,
                                                                    114)),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) {
                                                  return const Divider();
                                                },
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  DatePicker.showTimePicker(
                                                      context,
                                                      showTitleActions: true,
                                                      onChanged: (time) {
                                                    print("Changing");
                                                  }, onConfirm: (time) {
                                                    print(
                                                        "Confirm Time: $time");
                                                    setStateModal(() {
                                                      modalTime.add(
                                                          "${time.hour < 10 ? '0${time.hour}' : time.hour.toString()}:${time.minute < 10 ? '0${time.minute}' : time.minute.toString()}:${time.second < 10 ? '0${time.second}' : time.second.toString()}");
                                                    });
                                                  });
                                                },
                                                child: Text("เพิ่มเวลา")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  setStateModal(() {
                                                    Navigator.pop(
                                                        context, modalTime);
                                                  });
                                                },
                                                child: Text("ยืนยัน"))
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              }).then((value) {
                            setState(() {
                              timesForManual = value;
                            });
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        child: const Text(
                          "เพิ่ม",
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () async {
                          print(
                              "TimeForManual: ${timesForManual} and Mode: ${isRoutineType}");
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            if (user.currentUser!.uid.isNotEmpty) {
                              drug.uid = user.currentUser!.uid;
                            }
                            if (timesForManual.isEmpty && !isRoutineType) {
                              Fluttertoast.showToast(
                                msg: "กรุณาเพิ่มเวลา",
                                gravity: ToastGravity.CENTER,
                              );
                            } else if (selectedTimes.isEmpty && isRoutineType) {
                              Fluttertoast.showToast(
                                msg: "กรุณาเลือกเวลา",
                                gravity: ToastGravity.CENTER,
                              );
                            } else if (selectedActs.isEmpty && isRoutineType) {
                              Fluttertoast.showToast(
                                msg: "กรุณาเลือกว่ากินตอนไหน",
                                gravity: ToastGravity.CENTER,
                              );
                            } else {
                              print(
                                  "[${drug.uid}, ${drug.drugName}, ${drug.times}, ${drug.acts}]");
                              var response = await http
                                  .post(
                                      Uri.parse(
                                          'http://10.0.2.2:8000/addDrugByManual'),
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: jsonEncode({
                                        "typeOfAlarm": isRoutineType
                                            ? "routine"
                                            : "manual",
                                        "uid": drug.uid,
                                        "drugName": drug.drugName,
                                        "times": drug.times,
                                        "acts": drug.acts,
                                        "createDate": DateTime.now().toString(),
                                        "manualTimes": timesForManual
                                      }))
                                  .then((value) {
                                if (value.statusCode == 200) {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const FirstScreen();
                                  }));
                                } else {
                                  print(
                                      "can't post to http://10.0.2.2:8000/addDrugByManual");
                                }
                              });
                            }
                          }
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
