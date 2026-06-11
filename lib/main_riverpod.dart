import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/my_app.dart';
import 'riverpod_example/view/riverpod_notes_list_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(
        title: 'Riverpod SQLite Example',
        home: RiverpodNotesListPage(),
      ),
    ),
  );
}
