import 'package:flutter/material.dart';
import 'package:note_app_ikokas/pages/homepage.dart';
import 'package:note_app_ikokas/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_event.dart';
import 'package:note_app_ikokas/core/firebase_services.dart';
import 'package:note_app_ikokas/core/notes_repo.dart';
import 'package:note_app_ikokas/dbhelper/db_helper.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_bloc.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_event.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_state.dart';
import 'package:note_app_ikokas/core/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:note_app_ikokas/dbhelper/user_db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final localDb = LocalDbService();
  final userDb = UserLocalDbService();
  final repo = NotesRepository(FirebaseService(), localDb);
  final authRepo = AuthRepository(userDb);
  runApp(MyApp(repo: repo, authRepo: authRepo));
}

class MyApp extends StatelessWidget {
  final NotesRepository repo;
  final AuthRepository authRepo;
  const MyApp({super.key, required this.repo, required this.authRepo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepo)..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => NotesBloc(repo),
        ),
      ],
      child: MaterialApp(
        title: 'Ikokas Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Homepage(userId: state.user.uid);
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
