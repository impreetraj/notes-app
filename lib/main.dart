import 'package:flutter/material.dart';
import 'package:note_app_ikokas/pages/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app_ikokas/bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_event.dart';
import 'package:note_app_ikokas/core/firebase_services.dart';
import 'package:note_app_ikokas/core/notes_repo.dart';
import 'package:note_app_ikokas/dbhelper/db_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final repo = NotesRepository(FirebaseService(), LocalDbService());
  runApp(MyApp(repo: repo,));
}

class MyApp extends StatelessWidget {
  final repo;
  const MyApp({super.key , required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: BlocProvider(
        create: (_) => NotesBloc(repo)..add(LoadNotes()),
        child: const Homepage(),
      ),
    );
  }
}
