import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_event.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_state.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';

class BlocNoteDetailPage extends StatefulWidget {
  final NoteModel note;

  const BlocNoteDetailPage({super.key, required this.note});

  @override
  State<BlocNoteDetailPage> createState() => _BlocNoteDetailPageState();
}

class _BlocNoteDetailPageState extends State<BlocNoteDetailPage> {
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

    context.read<NoteBloc>().add(
      UpdateBlocNoteEvent(
        id: widget.note.id!,
        title: title,
        description: description,
      ),
    );
  }

  Future<void> deleteNote() async {
    context.read<NoteBloc>().add(DeleteBlocNoteEvent(id: widget.note.id!));
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
      appBar: AppBar(
        title: const Text('BLoC Note Detail'),
        actions: [
          IconButton(onPressed: deleteNote, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<NoteBloc, NoteState>(
          listener: (context, state) {
            if (state.completedAction == NoteAction.update ||
                state.completedAction == NoteAction.delete) {
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
                AppTextField(controller: titleController, label: 'Title'),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                state.isLoading
                    ? const CircularProgressIndicator()
                    : AppButton(text: 'Update Note', onPressed: updateNote),
              ],
            );
          },
        ),
      ),
    );
  }
}
