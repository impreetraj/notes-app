# note_app_ikokas

This is a Flutter note-taking application that utilizes the BLoC pattern for state management. It features a comprehensive Firebase backend integration and supports offline data caching.

The application handles authentication through Firebase Auth, supporting multiple providers: email/password, Google Sign-In (via the google_sign_in package), and Facebook Login (via the flutter_facebook_auth package). 

Notes are managed by a dedicated BLoC that handles CRUD operations. The primary data store is Cloud Firestore. When a user creates or modifies a note, the data is sent to Firestore. Concurrently, the application uses the sqflite package to cache notes and user data in a local SQLite database, allowing the app to function when offline. The app also uses SQLite to persist the user's UI theme preference (dark/light mode).

The application integrates Firebase Cloud Messaging (FCM) to handle push notifications. When the app receives a notification payload, it uses the flutter_local_notifications package to display the notification on the device.

For monitoring and stability, the app includes Firebase Analytics to track usage events and Firebase Crashlytics to automatically record and report application crashes.

Technologies used: Flutter, flutter_bloc, Firebase Core, Firebase Auth, Cloud Firestore, Firebase Messaging, Firebase Analytics, Firebase Crashlytics, google_sign_in, flutter_facebook_auth, sqflite, flutter_local_notifications.

## Working Flow
1. Open the app -> The app initializes Firebase services and checks SQLite for saved theme preferences and cached user data to render the initial state.
2. Authenticate -> The Auth BLoC processes login requests through Firebase Auth (Email, Google, or Facebook).
3. Load Notes -> The Notes BLoC fetches notes from Cloud Firestore and updates the UI. It also caches this data in the local SQLite database.
4. Create/Update Note -> The user submits note data. The Notes BLoC writes the document to Cloud Firestore and updates the local SQLite cache.
5. Receive Notification -> FCM delivers a message to the device. The app processes the payload and uses flutter_local_notifications to trigger a system-level notification alert.
6. Record Crash -> If an unhandled exception occurs during use, Firebase Crashlytics intercepts it and logs the stack trace to the Firebase console.
