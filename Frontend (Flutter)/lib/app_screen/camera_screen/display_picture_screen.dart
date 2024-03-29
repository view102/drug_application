import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:term_project/Object/Drug.dart';
import 'package:term_project/app_screen/camera_screen/camera_controller.dart';
import 'dart:io';

import 'package:term_project/app_screen/first_screen.dart';

class DisplayPictureScreen extends StatefulWidget {
  final XFile picture;
  const DisplayPictureScreen({Key? key, required this.picture})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DisplayPictureScreenState();
  }
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final user = FirebaseAuth.instance;
  late Future<Drug> drug;
  late Drug drugInfo;

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    drug = fetchPictureInfo();
    drug.then((value) => drugInfo = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Drug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to camera',
            onPressed: () async {
              await availableCameras().then((cameras) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return CameraPage(cameras: cameras);
                }));
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Drug>(
          future: drug,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // drug.then((value) => drugInfo = value);
              // print("INFO: DRUG_INFO = ${drugInfo.toString()}");
              return _buildrow(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('ERROR_SNAPSHOT: ${snapshot.error}');
            }
            return const Center(
              child: SizedBox(
                height: 20.0,
                width: 20.0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          var response = await http
              .post(Uri.parse('http://10.0.2.2:8000/addDrugByManual'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "typeOfAlarm": 'routine',
                    "uid": drugInfo.uid,
                    "drugName": drugInfo.drugName,
                    "times": drugInfo.times,
                    "acts": drugInfo.acts,
                    "createDate": DateTime.now().toString(),
                    "manualTimes": []
                  }))
              .then((value) {
            if (value.statusCode == 200) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const FirstScreen();
              }));
            } else {
              print("can't post to http://10.0.2.2:8000/addDrugByManual");
            }
          });
        },
        child: const Text("ยืนยันข้อมูล"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<Drug> fetchPictureInfo() async {
    print("DEBUG: 1");
    String imagePath = widget.picture.path;
    print("DEBUG: 2");
    File imageFile = File(imagePath);
    print("DEBUG: 3");
    Uint8List imageBytes = await imageFile.readAsBytes();
    print("DEBUG: 4");
    String base64String = base64.encode(imageBytes);
    print("DEBUG: 5");
    var response =
        await http.post(Uri.parse('http://10.0.2.2:8000/getTextToPreview'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "uid": user.currentUser!.uid,
              "image": base64String,
              "createDate": DateTime.now().toString()
            }));
    print("DEBUG: 6");
    final data = jsonDecode(response.body);
    print("DEBUG: 7");
    var drug = Drug.fromJson(data);
    print("DEBUG: 8");
    print(drug);
    return drug;
  }

  Widget _buildrow(drugInfo) {
    var dict_inverse = {
      "morning": "เช้า",
      "noon": "กลางวัน",
      "evening": "เย็น",
      "sleep": "ก่อนนอน",
      "beforeMeal": "ก่อนอาหาร",
      "afterMeal": "หลังอาหาร"
    };
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top,
        child: Column(children: [
          ListTile(
            title: Text(
                "ชื่อยา: ${drugInfo.drugName.isEmpty ? "ไม่พบชื่อยา" : drugInfo.drugName}"),
          ),
          ListTile(
            title: Wrap(children: [
              const Text("เวลาเเจ้งเตือน: "),
              drugInfo.times.isEmpty
                  ? const Text("ไม่พบช่วงเวลาการทานยา")
                  : const Text(""),
              for (var i in drugInfo.times) Text("${dict_inverse[i]}, ")
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Image.file(File(widget.picture.path), fit: BoxFit.cover),
          )
        ]),
      ),
    );
  }
}
