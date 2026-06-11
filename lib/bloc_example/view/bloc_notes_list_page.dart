import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_event.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_state.dart';
import 'package:flutter_state_management/core/api/api_service.dart';
import 'package:flutter_state_management/core/database/app_database.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository_impl.dart';
import 'package:flutter_state_management/core/widgets/app_button.dart';
import 'package:flutter_state_management/core/widgets/note_card.dart';

import 'bloc_add_note_page.dart';
import 'bloc_note_detail_page.dart';

class BlocNotesListPage extends StatelessWidget {
  const BlocNotesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = NoteRepositoryImpl(
          localDataSource: AppDatabase.instance,
          remoteDataSource: ApiService(),
          source: NoteSource.bloc,
        );

        return NoteBloc(repository: repository)..add(LoadBlocNotesEvent());
      },
      child: const BlocNotesListView(),
    );
  }
}

class BlocNotesListView extends StatelessWidget {
  const BlocNotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<NoteBloc>().add(LoadBlocNotesEvent());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              AppButton(
                key: const Key('bloc_add_note_button'),
                text: 'Add Local BLoC Note',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<NoteBloc>(),
                        child: const BlocAddNotePage(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Local SQLite Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (state.localNotes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No local notes found'),
                )
              else
                ...state.localNotes.map((note) {
                  return NoteCard(
                    note: note,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<NoteBloc>(),
                            child: BlocNoteDetailPage(note: note),
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<NoteBloc>().add(
                        DeleteBlocNoteEvent(id: note.id!),
                      );
                    },
                  );
                }),
              const SizedBox(height: 20),
              const Text(
                'Shared API Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...state.apiNotes.map((note) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.cloud)),
                    title: Text(note.title),
                    subtitle: Text(note.description),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
