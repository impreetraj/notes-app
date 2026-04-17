import 'package:flutter/material.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_bloc.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_event.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_state.dart';
import 'package:note_app_ikokas/pages/editpage.dart';

class Homepage extends StatefulWidget {
  final String userId;
  const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNotes(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ikokas Notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      backgroundColor: const Color(0xFFF8F9FA),

      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (_, state) {
          if (state is NotesLoaded) {

            return LayoutBuilder(
              builder: (context, constraints) {

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.notes.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    mainAxisExtent: 220,
                  ),

                  itemBuilder: (_, i) {
                    final note = state.notes[i];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  note.title.toUpperCase(), 
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A1A),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<NotesBloc>(),
                                          child: EditNotePage(note: note),
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    context.read<NotesBloc>().add(DeleteNote(note.id, widget.userId));
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Updated: ${DateTime.fromMillisecondsSinceEpoch(note.updatedAt).toString().substring(0, 16)}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
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

      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final titleController = TextEditingController();
          final contentController = TextEditingController();

          showDialog(
            context: context,
            builder: (_) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "New Note",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Title",
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Content",
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty ||
                              contentController.text.isEmpty) {
                            return;
                          }

                          final note = Note(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: widget.userId,
                            title: titleController.text,
                            content: contentController.text,
                            updatedAt: DateTime.now().millisecondsSinceEpoch,
                          );

                          context.read<NotesBloc>().add(AddNote(note));

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Save Note",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Note", style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
