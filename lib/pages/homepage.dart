import 'package:flutter/material.dart';
import 'package:note_app_ikokas/bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:note_app_ikokas/pages/editpage.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes Apps Ikokas")),

      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (_, state) {
          if (state is NotesLoaded) {

            return LayoutBuilder(
              builder: (context, constraints) {

                /// 📱 Only phone responsive
                int crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.notes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),

                  itemBuilder: (_, i) {
                    final note = state.notes[i];

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 162, 175, 182),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// 🔹 HEADER
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: Row(
                              children: [

                                /// ✅ Responsive title
                                Expanded(
                                  child: Text(
                                    note.title.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                /// ✏️ Edit
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<NotesBloc>(),
                                          child: EditNotePage(note: note),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                /// 🗑 Delete
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () {
                                    context.read<NotesBloc>().add(
                                      DeleteNote(note.id),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          
                          Expanded(
                            child: Text(
                              note.content,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),

      /// ➕ ADD NOTE
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          final titleController = TextEditingController();
          final contentController = TextEditingController();

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text("Add Note"),

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: "Content"),
                    ),
                  ],
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: () {

                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        return;
                      }

                      final note = Note(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        content: contentController.text,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      context.read<NotesBloc>().add(AddNote(note));

                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}