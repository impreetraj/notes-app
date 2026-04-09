import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_event.dart';
import 'package:note_app_ikokas/model/note_model.dart';


class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Note")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController),
            TextField(controller: contentController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final updated = Note(
                  id: widget.note.id,
                  title: titleController.text,
                  content: contentController.text,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                );

                context.read<NotesBloc>().add(UpdateNote(updated));
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}