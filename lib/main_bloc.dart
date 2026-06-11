import 'package:flutter/material.dart';

import 'app/my_app.dart';
import 'bloc_example/view/bloc_notes_list_page.dart';

void main() {
  runApp(const MyApp(title: 'BLoC SQLite Example', home: BlocNotesListPage()));
}
