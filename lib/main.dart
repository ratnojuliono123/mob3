
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mob3_ubg_kelompok12/firebase_options.dart';
import 'package:mob3_ubg_kelompok12/input_data/data_angsuran.dart';
import 'package:mob3_ubg_kelompok12/input_data/data_pinjaman.dart';
import 'package:mob3_ubg_kelompok12/login/dasboard_admin.dart';
import 'package:mob3_ubg_kelompok12/login/form_login.dart';



void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: LoginPage(),
    );
  }
}