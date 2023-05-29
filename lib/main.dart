import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator("127.0.0.1", 9099);
  FirebaseFirestore.instance.useFirestoreEmulator("127.0.0.1", 8080);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _insertInFirestore() {
    var db = FirebaseFirestore.instance;
    // db.collection('agc').add({
    //   'name': 'David',
    //   'age': 30,
    // });
  }

  Future<void> _login() async {
    var auth = FirebaseAuth.instance;

    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
    await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  StreamSubscription<User?> checarUsuario() {
    return FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        const Text('User is currently signed out!');
      } else {
        const Text('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            // Handle different states based on the snapshot
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While the authentication state is being determined
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // If an error occurred while retrieving the authentication state
              return Text('Error: ${snapshot.error}');
            } else {
              // If the authentication state is available
              if (snapshot.hasData) {
                // User is signed in
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('User is signed in: ${snapshot.data!.uid}'),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                );
              } else {
                // User is signed out
                return const Text('User is signed out');
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
