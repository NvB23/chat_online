import 'package:chat_online/screens/chat_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  // FirebaseFirestore.instance.collection("mensagens").snapshots().listen((data) {
  //   data.docs.forEach((d) {
  //     print(d.data());
  //   });
  // });

  // FirebaseFirestore.instance
  //     .collection("mensagens")
  //     .doc()
  //     .set({"nome": "Pedro", "texto": "Hello!"});

  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("mensagens").get();

  // snapshot.docs.forEach((d) {
  //   print("${d.id} - ${d.data()}");
  //   d.reference.update({"nome": "naum"});
  // });

  // DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //     .collection("mensagens")
  //     .doc("ToOhDyRvEo80Vd5LlhAh")
  //     .get();

  // print(snapshot.data());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatScreens(),
    );
  }
}
