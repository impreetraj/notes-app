import 'package:flutter/material.dart';
import 'package:note_app_ikokas/core/notification_service.dart';
import 'package:note_app_ikokas/pages/homepage.dart';
import 'package:note_app_ikokas/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:note_app_ikokas/core/fcm_service.dart';
import 'package:note_app_ikokas/bloc/notes_bloc/notes_bloc.dart';
import 'package:note_app_ikokas/core/firebase_services.dart';
import 'package:note_app_ikokas/core/notes_repo.dart';

import 'package:note_app_ikokas/dbhelper/db_helper.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_bloc.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_event.dart';
import 'package:note_app_ikokas/bloc/auth_bloc/auth_state.dart';
import 'package:note_app_ikokas/core/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_bloc.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_state.dart';
import 'package:note_app_ikokas/bloc/theme_bloc/theme_event.dart';
import 'package:note_app_ikokas/bloc/notification_bloc/notification_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:note_app_ikokas/dbhelper/user_db_helper.dart';
import 'package:note_app_ikokas/pages/splash_screen.dart';
import 'package:note_app_ikokas/dbhelper/theme_db_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  
  await NotificationService.instance.init();


  await initFCM();


  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final currentUser = FirebaseAuth.instance.currentUser;
  final initialRoute = currentUser != null ? '/main_logic' : '/';

  final localDb = LocalDbService();
  final userDb = UserLocalDbService();
  final themeDb = ThemeLocalDbService();
  final initialTheme = await themeDb.getTheme();

  final firebaseService = FirebaseService();
  final repo = NotesRepository(firebaseService, localDb);
  final authRepo = AuthRepository(userDb);
  runApp(
    MyApp(
      firebaseService: firebaseService,
      repo: repo,
      authRepo: authRepo,
      themeDb: themeDb,
      isDarkMode: initialTheme.isDarkMode,
      initialRoute: initialRoute,
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final NotesRepository repo;
  final AuthRepository authRepo;
  final ThemeLocalDbService themeDb;
  final bool isDarkMode;
  final String initialRoute;
  const MyApp({
    super.key,
    required this.firebaseService,
    required this.repo,
    required this.authRepo,
    required this.themeDb,
    required this.isDarkMode,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepo)..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => NotificationBloc(firebaseService: firebaseService)),
        BlocProvider(
          create: (context) => NotesBloc(
            repo,
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (_) => ThemeBloc(themeDb, initialIsDarkMode: isDarkMode),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Ikokas Notes',
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            initialRoute: initialRoute,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
            routes: {
              '/': (context) => const SplashScreen(),
              '/main_logic': (context) => BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return FcmListenerWrapper(
                      userId: state.user.uid,
                    );
                  }
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const LoginPage();
                },
              ),
            },
          );
        },
      ),
    );
  }
}
