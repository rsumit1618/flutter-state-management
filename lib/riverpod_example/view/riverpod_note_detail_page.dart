import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';
import 'package:flutter_state_management/riverpod_example/viewmodel/riverpod_note_view_model.dart';

class RiverpodNoteDetailPage extends ConsumerStatefulWidget {
  final NoteModel note;

  const RiverpodNoteDetailPage({super.key, required this.note});

  @override
  ConsumerState<RiverpodNoteDetailPage> createState() =>
      _RiverpodNoteDetailPageState();
}

class _RiverpodNoteDetailPageState
    extends ConsumerState<RiverpodNoteDetailPage> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note.title);
    descriptionController = TextEditingController(
      text: widget.note.description,
    );
  }

  Future<void> updateNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    final didUpdate = await ref
        .read(riverpodNoteViewModelProvider.notifier)
        .updateNote(
          id: widget.note.id!,
          title: title,
          description: description,
        );

    if (mounted && didUpdate) {
      Navigator.pop(context);
    } else if (mounted) {
      _showError();
    }
  }

  Future<void> deleteNote() async {
    final didDelete = await ref
        .read(riverpodNoteViewModelProvider.notifier)
        .deleteNote(widget.note.id!);

    if (mounted && didDelete) {
      Navigator.pop(context);
    } else if (mounted) {
      _showError();
    }
  }

  void _showError() {
    final error = ref.read(riverpodNoteViewModelProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'Operation failed')),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(riverpodNoteViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Note Detail'),
        actions: [
          IconButton(onPressed: deleteNote, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(controller: titleController, label: 'Title'),
            const SizedBox(height: 12),
            AppTextField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            notesState.isLoading
                ? const CircularProgressIndicator()
                : AppButton(text: 'Update Note', onPressed: updateNote),
          ],
        ),
      ),
    );
  }
}
