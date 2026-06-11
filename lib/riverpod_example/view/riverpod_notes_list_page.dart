import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/note_card.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';
import 'package:flutter_state_management/riverpod_example/view/riverpod_add_note_page.dart';
import 'package:flutter_state_management/riverpod_example/view/riverpod_note_detail_page.dart';
import 'package:flutter_state_management/riverpod_example/viewmodel/riverpod_note_view_model.dart';

class RiverpodNotesListPage extends ConsumerWidget {
  const RiverpodNotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(riverpodNoteViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(riverpodNoteViewModelProvider.notifier).reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: asyncNotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              AppButton(
                text: 'Retry',
                onPressed: () {
                  ref.read(riverpodNoteViewModelProvider.notifier).reload();
                },
              ),
            ],
          ),
        ),
        data: (notes) => _NotesList(
          notes: notes,
          onDelete: (id) {
            ref.read(riverpodNoteViewModelProvider.notifier).deleteNote(id);
          },
        ),
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  final NotesSnapshot notes;
  final ValueChanged<int> onDelete;

  const _NotesList({required this.notes, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AppButton(
          key: const Key('riverpod_add_note_button'),
          text: 'Add Local Riverpod Note',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiverpodAddNotePage()),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Local SQLite Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (notes.localNotes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No local notes found'),
          )
        else
          ...notes.localNotes.map((note) {
            return NoteCard(
              note: note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiverpodNoteDetailPage(note: note),
                  ),
                );
              },
              onDelete: () {
                onDelete(note.id!);
              },
            );
          }),
        const SizedBox(height: 20),
        const Text(
          'Shared API Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...notes.apiNotes.map((note) {
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
  }
}
