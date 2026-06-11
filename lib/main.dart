import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'bloc_example/view/bloc_notes_list_page.dart';
import 'getx_example/view/getx_notes_list_page.dart';
import 'interview_examples/view/interview_concepts_page.dart';
import 'riverpod_example/view/riverpod_notes_list_page.dart';

void main() {
  runApp(const ProviderScope(child: MainMenuApp()));
}

class MainMenuApp extends StatelessWidget {
  const MainMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter State Management Lab'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ExampleButton(
            key: Key('open_bloc_example'),
            title: 'BLoC Notes Example',
            description: 'SQLite + Shared API + Shared UI + BLoC',
            page: BlocNotesListPage(),
          ),
          SizedBox(height: 12),
          _ExampleButton(
            key: Key('open_getx_example'),
            title: 'GetX Notes Example',
            description: 'SQLite + Shared API + Shared UI + GetX',
            page: GetxNotesListPage(),
          ),
          SizedBox(height: 12),
          _ExampleButton(
            key: Key('open_riverpod_example'),
            title: 'Riverpod Notes Example',
            description: 'SQLite + Shared API + Shared UI + Riverpod',
            page: RiverpodNotesListPage(),
          ),
          SizedBox(height: 12),
          _ExampleButton(
            key: Key('open_interview_concepts'),
            title: 'Flutter Interview Concepts',
            description:
                'Lifecycle + async builders + keys + responsive layout',
            page: InterviewConceptsPage(),
          ),
        ],
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  final String title;
  final String description;
  final Widget page;

  const _ExampleButton({
    super.key,
    required this.title,
    required this.description,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
