import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:term_project/Object/DrugHistory.dart';
import 'package:http/http.dart' as http;

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SecondScreen();
  }
}

class _SecondScreen extends State<SecondScreen> {
  late Future<List<DrugHistory>> drugs;

  @override
  void initState() {
    print("initState Second Screen"); // สำหรับทดสอบ
    super.initState();
    drugs = fetchDrug();
    drugs.then((value) => print(value));
    print("finish initState");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<DrugHistory>>(
      future: drugs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // กรณีมีข้อมูล
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              print(snapshot.data);
              return _buildRow(snapshot.data, index);
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
    ));
  }

  Widget _buildRow(drugs, index) {
    print("in build row");
    DrugHistory drug = drugs[index];
    return Card(
      child: ListTile(
        title: Text(drug.drugName),
        subtitle: Text(drug.lastDate),
      ),
    );
  }

  Future<List<DrugHistory>> fetchDrug() async {
    var uid;
    final user = FirebaseAuth.instance;
    if (user.currentUser!.uid.isNotEmpty) {
      uid = user.currentUser!.uid;
    }
    print(uid);
    //Ios
    // var response = await http.post(Uri.parse('http://127.0.0.1:8000/getDrugById'),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       "uid": uid,
    //     }));

    //Android
    var response = await http.post(Uri.parse('http://10.0.2.2:8000/getHistory'),
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
      var result;
      if (!response.body.isEmpty) {
        result = parseDrug(response.body);
      } else {
        result = [];
      }
      return result;
    } else {
      // กรณี error
      print("2");
      throw Exception('Failed to load article');
    }
  }

// ฟังก์ชั่นแปลงข้อมูล JSON String data เป็น เป็นข้อมูล List<Article>
  List<DrugHistory> parseDrug(String responseBody) {
    print("parseDrug");
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    print(parsed
        .map<DrugHistory>((json) => DrugHistory.fromJson(json))
        .toList()
        .toString());
    return parsed
        .map<DrugHistory>((json) => DrugHistory.fromJson(json))
        .toList();
  }
}
