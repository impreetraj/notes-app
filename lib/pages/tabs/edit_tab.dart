import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/model/note_model.dart';

class EditTab extends StatefulWidget {
  final Note? note;
  final VoidCallback? onSave;

  const EditTab({super.key, this.note, this.onSave});

  @override
  State<EditTab> createState() => _EditTabState();
}

class _EditTabState extends State<EditTab> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  String selectedPlatform = "Google";
  String selectedTime = "09:00";
  String selectedDay = "Today";

  final times = List.generate(48, (index) {
    final hour = index ~/ 2;
    final minute = (index % 2) * 30;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  });

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    titleController = TextEditingController(text: widget.note?.title ?? "");
    contentController = TextEditingController(text: widget.note?.content ?? "");
    selectedPlatform = widget.note?.platform ?? "Google";
    selectedTime = widget.note?.timeSlot ?? "09:00";
    selectedDay = widget.note?.scheduleDay ?? "Today";
  }

  @override
  void didUpdateWidget(covariant EditTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note?.id != widget.note?.id) {
      _initControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.note == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text("No note selected to edit"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Edit Note", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(height: 32),
                  TextField(
                    controller: contentController,
                    maxLines: null,
                    minLines: 8,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    decoration: const InputDecoration(
                      hintText: "Write your note here...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(height: 32),
                  
                  // Platform
                  const Text("Platform", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Microsoft", style: TextStyle(fontSize: 12)),
                          value: "Microsoft",
                          groupValue: selectedPlatform,
                          onChanged: (v) => setState(() => selectedPlatform = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Google", style: TextStyle(fontSize: 12)),
                          value: "Google",
                          groupValue: selectedPlatform,
                          onChanged: (v) => setState(() => selectedPlatform = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Time
                  const Text("Time Slot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => selectedTime = v!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Day
                  const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Today", style: TextStyle(fontSize: 13)),
                          value: "Today",
                          groupValue: selectedDay,
                          onChanged: (v) => setState(() => selectedDay = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Tomorrow", style: TextStyle(fontSize: 13)),
                          value: "Tomorrow",
                          groupValue: selectedDay,
                          onChanged: (v) => setState(() => selectedDay = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await FirebaseAnalytics.instance.logEvent(
                  name: 'update_note',
                  parameters: {
                    'platform': selectedPlatform,
                    'timeSlot': selectedTime,
                    'scheduleDay': selectedDay,
                  },
                );
                final updated = Note(
                  id: widget.note!.id,
                  userId: widget.note!.userId,
                  title: titleController.text,
                  content: contentController.text,
                  platform: selectedPlatform,
                  timeSlot: selectedTime,
                  scheduleDay: selectedDay,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                );

                context.read<NotesBloc>().add(UpdateNote(updated));
                if (widget.onSave != null) widget.onSave!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Update Note",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}
