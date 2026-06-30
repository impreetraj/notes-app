import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_state.dart';
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_bloc.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_event.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_state.dart';

class Homepage extends StatelessWidget {
  final String userId;
  final Function(Note) onEdit;

  const Homepage({super.key, required this.userId, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Ikokas Notes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
          }
        },
        builder: (_, state) {
          List<Note> notes = [];
          if (state is NotesLoaded) notes = state.notes;
          else if (state is NoteActionSuccess) notes = state.notes;
          else if (state is NotesError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          else return const Center(child: CircularProgressIndicator());

          if (notes.isEmpty) {
            return const Center(child: Text("No notes found. Add a new note!", style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: notes.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: constraints.maxWidth > 600 ? 500 : 400,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  mainAxisExtent: 220,
                ),
                itemBuilder: (_, i) {
                  final note = notes[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(note.title.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.color,
                                        height: 1.2))),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) async{
                                if (value == 'edit') {
                                  onEdit(note);
                                } else if (value == 'delete') {
                                  await FirebaseAnalytics.instance.logEvent(name: 'delete_note');
                                  context.read<NotesBloc>().add(DeleteNote(note.id, userId));
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20, color: Colors.blue), SizedBox(width: 8), Text('Edit')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: Theme.of(context).dividerColor),
                        const SizedBox(height: 12),
                        // Chips for Platform, Time, and Day
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: note.platform == "Microsoft" ? Colors.blue.withOpacity(0.15) : Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(note.platform == "Microsoft" ? Icons.window : Icons.g_mobiledata, size: 14, color: note.platform == "Microsoft" ? Colors.blue : Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(note.platform, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: note.platform == "Microsoft" ? Colors.blue : Colors.orange)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                              child: Text("${note.scheduleDay} at ${note.timeSlot}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: Text(note.content, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.5), overflow: TextOverflow.fade)),
                        const SizedBox(height: 8),
                        Text("Updated: ${DateTime.fromMillisecondsSinceEpoch(note.updatedAt).toString().substring(0, 16)}", style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35), fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () => _showNewNoteDialog(context),
            backgroundColor: state.isDarkMode ? Colors.white : Colors.black,
            foregroundColor: state.isDarkMode ? Colors.black : Colors.white,
            icon: const Icon(Icons.add),
            label: const Text("Add Note",
                style: TextStyle(fontWeight: FontWeight.bold)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      ),
    );
  }

  void _showNewNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedPlatform = "Google";
    String selectedTime = "09:00";
    String selectedDay = "Today";

    final times = List.generate(48, (index) {
      final hour = index ~/ 2;
      final minute = (index % 2) * 30;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    });

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(28)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("New Notes",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    
                    // Title
                    TextField(controller: titleController, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: "Title", filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
                    const SizedBox(height: 16),
                    
                    // Content
                    TextField(controller: contentController, maxLines: 3, decoration: InputDecoration(hintText: "Description", filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
                    const SizedBox(height: 20),

                    // Platform Selection
                    const Text("Platform", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Microsoft", style: TextStyle(fontSize: 13)),
                            value: "Microsoft",
                            groupValue: selectedPlatform,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setDialogState(() => selectedPlatform = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Google", style: TextStyle(fontSize: 13)),
                            value: "Google",
                            groupValue: selectedPlatform,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setDialogState(() => selectedPlatform = v!),
                          ),
                        ),
                      ],
                    ),

                    // Time Selection
                    const Text("Time Slot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setDialogState(() => selectedTime = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Day Selection
                    const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Today", style: TextStyle(fontSize: 14)),
                            value: "Today",
                            groupValue: selectedDay,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setDialogState(() => selectedDay = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Tomorrow", style: TextStyle(fontSize: 14)),
                            value: "Tomorrow",
                            groupValue: selectedDay,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setDialogState(() => selectedDay = v!),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty) return;
                        await FirebaseAnalytics.instance.logEvent(
                          name: 'add_note',
                          parameters: {
                            'platform': selectedPlatform,
                            'timeSlot': selectedTime,
                            'scheduleDay': selectedDay,
                          },
                        );
                        final note = Note(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: userId,
                          title: titleController.text,
                          content: contentController.text,
                          platform: selectedPlatform,
                          timeSlot: selectedTime,
                          scheduleDay: selectedDay,
                          updatedAt: DateTime.now().millisecondsSinceEpoch,
                        );
                        context.read<NotesBloc>().add(AddNote(note));
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          foregroundColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0),
                      child: const Text("Submit",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextButton(onPressed: () { 
                    FirebaseCrashlytics.instance.crash();
                    Navigator.pop(ctx);}, child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
