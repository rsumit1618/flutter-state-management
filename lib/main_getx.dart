import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'getx_example/view/getx_notes_list_page.dart';

void main() {
  runApp(const GetxMainApp());
}

class GetxMainApp extends StatelessWidget {
  const GetxMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX SQLite Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const GetxNotesListPage(),
    );
  }
}
