import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_state.dart';
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:note_app_ikokas/pages/homepage.dart';
import 'package:note_app_ikokas/pages/tabs/edit_tab.dart';
import 'package:note_app_ikokas/pages/tabs/notification_tab.dart';
import 'package:note_app_ikokas/pages/tabs/profile_tab.dart';

class MainNavigationWrapper extends StatefulWidget {
  final String userId;
  const MainNavigationWrapper({super.key, required this.userId});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  Note? _currentEditingNote;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNotes(widget.userId));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      
    
      if (index == 1 && _currentEditingNote == null) {
        final state = context.read<NotesBloc>().state;
        List<Note> notes = [];
        if (state is NotesLoaded) notes = state.notes;
        else if (state is NoteActionSuccess) notes = state.notes;
        
        if (notes.isNotEmpty) {
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          _currentEditingNote = notes.first;
        }
      }
    });
  }

  void navigateToEdit(Note note) {
    setState(() {
      _currentEditingNote = note;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      Homepage(userId: widget.userId, onEdit: navigateToEdit),
      EditTab(
        note: _currentEditingNote,
        onSave: () => setState(() => _currentIndex = 0),
      ),
      NotificationTab(userId: widget.userId),
      ProfileTab(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: 'Edit'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Notification'),
              BottomNavigationBarItem(icon: Icon(Icons.person_2_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
