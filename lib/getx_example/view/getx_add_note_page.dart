import 'package:flutter/material.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/app_text_field.dart';
import 'package:flutter_state_management/getx_example/viewmodel/getx_note_controller.dart';
import 'package:get/get.dart';

class GetxAddNotePage extends StatefulWidget {
  const GetxAddNotePage({super.key});

  @override
  State<GetxAddNotePage> createState() => _GetxAddNotePageState();
}

class _GetxAddNotePageState extends State<GetxAddNotePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final controller = Get.find<GetxNoteController>();

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    final didSave = await controller.addNote(
      title: title,
      description: description,
    );

    if (mounted && didSave) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage.value ?? 'Save failed')),
      );
    }
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
      appBar: AppBar(title: const Text('Add GetX Note')),
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
                  : AppButton(
                      key: const Key('getx_save_note_button'),
                      text: 'Save Note',
                      onPressed: saveNote,
                    ),
            ],
          );
        }),
      ),
    );
  }
}
