import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:term_project/app_screen/first_screen.dart';

import '../../Object/Profile.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: "", password: "");
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Scaffold(
            appBar: AppBar(title: const Text("Error"),),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
          return Scaffold(
            appBar: AppBar(title: const Text("เข้าสู่ระบบ"),),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("อีเมล", style: TextStyle(fontSize: 20),),
                        TextFormField(
                          validator: MultiValidator([
                            RequiredValidator(errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                            EmailValidator(errorText: "รูปเเบบอีเมลไม่ถูกต้อง")
                          ]
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (String? email){
                            profile.email = email!;
                          },
                        ),
                        const SizedBox(height: 15,),
                        const Text("รหัสผ่าน", style: TextStyle(fontSize: 20),),
                        TextFormField(
                          validator: RequiredValidator(
                              errorText: "กรุณาป้อนรหัสผ่านด้วยครับ"
                          ),
                          obscureText: true,
                          onSaved: (String? password){
                            profile.password = password!;
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: const Text("ลงชื่อเข้าใช้", style: TextStyle(fontSize: 20),),
                            onPressed: () async {
                              if(formKey.currentState!.validate()){
                                formKey.currentState!.save();
                                print("email = ${profile.email} password = ${profile.password}");
                                try{
                                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: profile.email, password: profile.password).then((value){
                                    formKey.currentState!.reset();
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                      return const FirstScreen();
                                    }));
                                  });
                                }on FirebaseAuthException catch(e) {
                                  // print(e.code);
                                  // print(e.message);
                                  Fluttertoast.showToast(
                                    msg: e.message!,
                                    gravity: ToastGravity.CENTER,
                                  );
                                }
                              }
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}