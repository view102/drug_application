import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:term_project/Object/DrugFda.dart';
import 'package:term_project/Object/DrugHistory.dart';
import 'package:http/http.dart' as http;

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ThirdScreen();
  }
}

class _ThirdScreen extends State<ThirdScreen> {
  final formKey = GlobalKey<FormState>();
  String drugNameSearch = "";
  late Future<List<DrugFda>> drugsFda;

  @override
  void initState() {
    print("initState Second Screen"); // สำหรับทดสอบ
    super.initState();
    drugsFda = fetchDrug(drugNameSearch);
    drugsFda.then((value) => print(value));
    print("finish initState");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ชื่อยา",
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (String? name) {
                    drugNameSearch = name!;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: OutlinedButton(
                      onPressed: () {
                        print(drugNameSearch);
                        setState(() {
                          drugsFda = fetchDrug(drugNameSearch);
                        });
                      },
                      child: Text("ค้นหา")),
                ),
                FutureBuilder(
                  future: drugsFda,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildRow(snapshot.data);
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
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildRow(drugs) {
    print("in build row");
    // DrugFda drug = drugs[0];
    
    return Column(
      children: [
        for (var i = 0; i < drugs.length; i++)
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(drugs[i].brandName),
                  subtitle: Text(drugs[i].genericName),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(drugs[i].indicationsAndUsage),
                )
              ],
            ),
          ),
      ],
    );
  }

  Future<List<DrugFda>> fetchDrug(drugName) async {
    var response =
        await http.post(Uri.parse('http://10.0.2.2:8000/searchDrugFda'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "drugName": drugName,
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
  List<DrugFda> parseDrug(String responseBody) {
    print("parseDrug");
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    print(parsed
        .map<DrugFda>((json) => DrugFda.fromJson(json))
        .toList()
        .toString());
    return parsed.map<DrugFda>((json) => DrugFda.fromJson(json)).toList();
  }
}
