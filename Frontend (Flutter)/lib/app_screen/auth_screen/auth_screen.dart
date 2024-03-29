import 'package:flutter/material.dart';
import 'package:term_project/app_screen/auth_screen/login_screen.dart';
import 'package:term_project/app_screen/auth_screen/register_screen.dart';

class AuthScreen extends StatelessWidget{
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register/Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                          return const RegisterScreen();
                        })
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("สร้างบัญชีผู้ใช้", style: TextStyle(fontSize: 20),)
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context){
                              return const LoginScreen();
                            }
                        )
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 20),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}