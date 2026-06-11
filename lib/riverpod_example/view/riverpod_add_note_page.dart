import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';
import 'package:flutter_state_management/riverpod_example/viewmodel/riverpod_note_view_model.dart';

class RiverpodAddNotePage extends ConsumerStatefulWidget {
  const RiverpodAddNotePage({super.key});

  @override
  ConsumerState<RiverpodAddNotePage> createState() =>
      _RiverpodAddNotePageState();
}

class _RiverpodAddNotePageState extends ConsumerState<RiverpodAddNotePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    final didSave = await ref
        .read(riverpodNoteViewModelProvider.notifier)
        .addNote(title: title, description: description);

    if (mounted && didSave) {
      Navigator.pop(context);
    } else if (mounted) {
      _showError();
    }
  }

  void _showError() {
    final error = ref.read(riverpodNoteViewModelProvider).error;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error?.toString() ?? 'Save failed')));
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
      appBar: AppBar(title: const Text('Add Riverpod Note')),
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
                : AppButton(
                    key: const Key('riverpod_save_note_button'),
                    text: 'Save Note',
                    onPressed: saveNote,
                  ),
          ],
        ),
      ),
    );
  }
}
