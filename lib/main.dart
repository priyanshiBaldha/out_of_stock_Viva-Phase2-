import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:out_of_stock_app/view/home_screen.dart';

import 'controller/database_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataBaseController dataBaseController = Get.put(DataBaseController());

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
