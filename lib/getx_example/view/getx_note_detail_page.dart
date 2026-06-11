import 'package:flutter/material.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';
import 'package:flutter_state_management/getx_example/viewmodel/getx_note_controller.dart';
import 'package:get/get.dart';

class GetxNoteDetailPage extends StatefulWidget {
  final NoteModel note;

  const GetxNoteDetailPage({super.key, required this.note});

  @override
  State<GetxNoteDetailPage> createState() => _GetxNoteDetailPageState();
}

class _GetxNoteDetailPageState extends State<GetxNoteDetailPage> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  final controller = Get.find<GetxNoteController>();

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

    final didUpdate = await controller.updateNote(
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
    final didDelete = await controller.deleteNote(widget.note.id!);

    if (mounted && didDelete) {
      Navigator.pop(context);
    } else if (mounted) {
      _showError();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.errorMessage.value ?? 'Operation failed'),
      ),
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
      appBar: AppBar(
        title: const Text('GetX Note Detail'),
        actions: [
          IconButton(onPressed: deleteNote, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
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
              controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : AppButton(text: 'Update Note', onPressed: updateNote),
            ],
          );
        }),
      ),
    );
  }
}
