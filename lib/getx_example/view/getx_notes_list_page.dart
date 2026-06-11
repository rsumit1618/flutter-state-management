import 'package:flutter/material.dart';
import 'package:flutter_state_management/core/api/api_service.dart';
import 'package:flutter_state_management/core/database/app_database.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository_impl.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/note_card.dart';
import 'package:flutter_state_management/getx_example/viewmodel/getx_note_controller.dart';
import 'package:get/get.dart';

import 'getx_add_note_page.dart';
import 'getx_note_detail_page.dart';

class GetxNotesListPage extends StatefulWidget {
  const GetxNotesListPage({super.key});

  @override
  State<GetxNotesListPage> createState() => _GetxNotesListPageState();
}

class _GetxNotesListPageState extends State<GetxNotesListPage> {
  late final GetxNoteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      GetxNoteController(
        repository: NoteRepositoryImpl(
          localDataSource: AppDatabase.instance,
          remoteDataSource: ApiService(),
          source: NoteSource.getx,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<GetxNoteController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.loadAllNotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            AppButton(
              key: const Key('getx_add_note_button'),
              text: 'Add Local GetX Note',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetxAddNotePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Local SQLite Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (controller.localNotes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No local notes found'),
              )
            else
              ...controller.localNotes.map((note) {
                return NoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GetxNoteDetailPage(note: note),
                      ),
                    );
                  },
                  onDelete: () {
                    controller.deleteNote(note.id!);
                  },
                );
              }),
            const SizedBox(height: 20),
            const Text(
              'Shared API Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...controller.apiNotes.map((note) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.cloud)),
                  title: Text(note.title),
                  subtitle: Text(note.description),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
