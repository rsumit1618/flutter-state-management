import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_event.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_state.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';

class BlocAddNotePage extends StatefulWidget {
  const BlocAddNotePage({super.key});

  @override
  State<BlocAddNotePage> createState() => _BlocAddNotePageState();
}

class _BlocAddNotePageState extends State<BlocAddNotePage> {
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

    context.read<NoteBloc>().add(
      AddBlocNoteEvent(title: title, description: description),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add BLoC Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<NoteBloc, NoteState>(
          listener: (context, state) {
            if (state.completedAction == NoteAction.add) {
              Navigator.pop(context);
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                AppTextField(
                  controller: titleController,
                  label: 'Title',
                  fieldKey: const Key('bloc_note_title_field'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descriptionController,
                  label: 'Description',
                  maxLines: 3,
                  fieldKey: const Key('bloc_note_description_field'),
                ),
                const SizedBox(height: 20),
                state.isLoading
                    ? const CircularProgressIndicator()
                    : AppButton(
                        key: const Key('bloc_save_note_button'),
                        text: 'Save Note',
                        onPressed: saveNote,
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
